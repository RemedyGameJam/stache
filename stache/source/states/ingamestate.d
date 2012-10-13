module stache.states.ingamestate;

import std.string;

import stache.i.statemachine;
import stache.game;

import fuji.render;
import fuji.matrix;

import stache.util.eventtypes;
import stache.i.entity;

import stache.entity.combatant;

import fuji.filesystem;

import std.xml;

import stache.thinkers.localplayer;
import stache.thinkers.nullthinker;


class InGameState : IState
{
	void OnAdd(StateMachine statemachine)
	{
		owner = statemachine;
	}

	void OnEnter()
	{
		size_t length;
		const(char*) rawData = MFFileSystem_Load("apachearena.xml", &length, false);

		string data = rawData[0 .. length].idup;
		try
		{
			check(data);
		}
		catch (CheckException e)
		{
			string failure = e.toString();
		}

		DocumentParser doc = new DocumentParser(data);

		ParseArena(doc);

		// Leaks like a bitch
		//MFHeap_Free(rawData);

		resetEvent();
	}

	void OnExit()
	{
	}

	void OnUpdate()
	{
		thinkEvent();
		updateEvent();
	}

	@property StateMachine Owner() { return owner; }

	private StateMachine owner;

	///IRenderable
	void OnRenderWorld()
	{
		MFRenderer_SetClearColour(0.1, 0.0, 0.1, 1.0);
		MFRenderer_ClearScreen(MFClearScreenFlags.All);

		MFView_Push();
		{
			float x = MFDeg2Rad!60;
			MFView_ConfigureProjection(x, 0.01, 100000);
			// TODO: Nasty singletonses
			float ratio = Game.Instance.mfInitParams.display.displayRect.width / Game.Instance.mfInitParams.display.displayRect.height;
			MFView_SetAspectRatio(ratio);
			MFView_SetProjection();

			MFMatrix mat;

			mat.t = MFVector(5, 2, 0, 1);

			MFView_SetCameraMatrix(mat);

			renderWorldEvent();
		}
		MFView_Pop();
	}

	void OnRenderGUI(MFRect orthoRect)
	{
		renderGUIEvent(orthoRect);
	}

	@property bool CanRenderWorld() { return true; }
	@property bool CanRenderGUI() { return true; }

	void ParseArena(DocumentParser parser)
	{
		parser.onStartTag["arena"] = (ElementParser arenaTag)
		{
			arenaTag.onStartTag["entities"] = (ElementParser entitiesTag)
			{
				entitiesTag.onStartTag["entity"] = (ElementParser entityTag)
				{
					CreateEntity(entityTag.tag.attr["type"], entityTag);

					entityTag.parse();
				};

				entitiesTag.parse();
			};

			arenaTag.parse();
		};

		parser.parse();
	}

	IEntity CreateEntity(string type, ElementParser parser = null)
	{
		Object entity = Object.factory("stache.entity." ~ toLower(type) ~ "." ~ type);

		if (entity !is null)
		{
			IEntity actualEntity = cast(IEntity) entity;

			if (actualEntity !is null)
			{
				actualEntity.OnCreate(parser);
				AddEntity(actualEntity);
			}
			if (cast(IRenderable) entity !is null)
			{
				AddRenderable(cast(IRenderable) entity);
			}
			if (cast(Combatant) entity !is null)
			{
				AddCombatant(cast(Combatant) entity);
			}
		}

		return cast(IEntity) entity;
	}

	void AddEntity(IEntity entity)
	{
		resetEvent.subscribe(&entity.OnReset);

		if (entity.CanUpdate)
			updateEvent.subscribe(&entity.OnUpdate);

		entities ~= entity;
	}

	void AddRenderable(IRenderable renderable)
	{
		if (renderable.CanRenderWorld)
			renderWorldEvent.subscribe(&renderable.OnRenderWorld);
		if (renderable.CanRenderGUI)
			renderGUIEvent.subscribe(&renderable.OnRenderGUI);
	}

	void AddCombatant(Combatant combatant)
	{
		IThinker thinker;

		if (combatant.Name == "Player1")
		{
			thinker = new LocalPlayer;
		}
		else
		{
			thinker = new NullThinker;
		}

		if (thinker.OnAssign(combatant))
		{
			thinkEvent.subscribe(&thinker.OnThink);
		}

		thinkers ~= thinker;
	}

	private VoidEvent resetEvent;

	private VoidEvent thinkEvent;
	private VoidEvent updateEvent;

	private VoidEvent renderWorldEvent;
	private MFRectEvent renderGUIEvent;

	private IEntity[] entities;
	private IThinker[] thinkers;
}
