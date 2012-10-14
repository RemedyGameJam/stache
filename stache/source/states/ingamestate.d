module stache.states.ingamestate;

import fuji.filesystem;
import fuji.render;
import fuji.matrix;
import fuji.material;
import fuji.primitive;
import fuji.system;
import fuji.font;

import std.xml;
import std.string;
import std.conv;

import stache.i.statemachine;
import stache.game;

import stache.util.eventtypes;

import stache.i.entity;
import stache.entity.combatant;

import stache.thinkers.localplayer;
import stache.thinkers.nullthinker;

import stache.i.collider;

import stache.sound.soundset;
import stache.sound.music;

class InGameState : IState
{
	enum RoundState
	{
		WaitForTwo,
		PreRound,
		Battle,
		PostRound
	}

	this()
	{
		roundBeginEvent += &OnRoundBegin;
		roundEndEvent += &OnRoundEnd;
	}

	void OnAdd(StateMachine statemachine)
	{
		owner = statemachine;
	}

	void OnEnter()
	{
		collision = new CollisionManager;

		arial = MFFont_Create("Arial");

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

		collision.PlaneDimensions = dimensions;

		// Leaks like a bitch
		//MFHeap_Free(rawData);


		roundState = RoundState.WaitForTwo;
		roundTimer = 2;

		resetEvent();

//		if(music)
//			music.Playing = true;
	}

	void OnExit()
	{
		foreach(mat; materials)
		{
			MFMaterial_Destroy(mat.mat);
		}

		collision = null;
	}

	void OnUpdate()
	{
		if(roundState != RoundState.WaitForTwo)
			roundTimer -= MFSystem_GetTimeDelta();

		final switch(roundState) with(RoundState)
		{
			case WaitForTwo:
				roundTimer -= 1;
				if(roundTimer <= 0)
				{
					// begin pre-round countdown
					roundState = RoundState.PreRound;
					roundTimer = 5;
				}
				break;
			case PreRound:
				if(roundTimer <= 0)
				{
					roundState = Battle;
					roundBeginEvent();
				}
				break;

			case Battle:
				if(roundTimer <= 0)
				{
					roundState = PostRound;
					roundEndEvent();
				}

				thinkEvent();
				break;

			case PostRound:
				break;
		}

		updateEvent();
		collision.OnUpdate();
		postUpdateEvent();
	}

	void OnRoundBegin()
	{
		roundTimer = roundLength;

		if(sounds)
			sounds.Play("begin");
	}

	void OnRoundEnd()
	{
		if(sounds)
			sounds.Play("end");
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

			MFMaterial_SetMaterial(materials["floor"].mat);

			MFPrimitive(PrimType.TriStrip | PrimType.Prelit, 0);
			MFMatrix ident = MFMatrix.identity;

			MFSetMatrix(ident);

			foreach(offsetX; -3 .. 3)
			{
				foreach(offsetZ; -3 .. 3)
				{
					float xVal = dimensions.x * offsetX;
					float zVal = dimensions.z * offsetZ;

					MFBegin(4);
					{
						MFSetTexCoord1(0, 1);
						MFSetPosition(xVal, 0, zVal);

						MFSetTexCoord1(0, 0);
						MFSetPosition(xVal, 0, zVal + dimensions.z);

						MFSetTexCoord1(1, 1);
						MFSetPosition(xVal + dimensions.x, 0, zVal);

						MFSetTexCoord1(1, 0);
						MFSetPosition(xVal + dimensions.x, 0, zVal + dimensions.z);
					}
					MFEnd();
				}
			}

			MFMaterial_SetMaterial(materials["backwall"].mat);

			MFPrimitive(PrimType.TriStrip | PrimType.Prelit, 0);

			foreach(offsetX; -3 .. 3)
			{
				foreach(offsetY; 0 .. 2)
				{
					float xVal = dimensions.x * offsetX;
					float yVal = dimensions.x * offsetY;

					MFBegin(4);
					{
						MFSetTexCoord1(0, 1);
						MFSetPosition(xVal, yVal, dimensions.z);

						MFSetTexCoord1(0, 0);
						MFSetPosition(xVal, yVal + dimensions.x, dimensions.z);

						MFSetTexCoord1(1, 1);
						MFSetPosition(xVal + dimensions.x, yVal, dimensions.z);

						MFSetTexCoord1(1, 0);
						MFSetPosition(xVal + dimensions.x, yVal + dimensions.x, dimensions.z);
					}
					MFEnd();
				}
			}
		}
		MFView_Pop();
	}

	void OnRenderGUI(MFRect orthoRect)
	{
		renderGUIEvent(orthoRect);

		switch(roundState) with(RoundState)
		{
			case PreRound:
				if(roundTimer < 3)
				{
					int countDown = cast(int)(roundTimer + 1);
					float interval = roundTimer - cast(int)roundTimer;
					float t = roundTimer / 3;

					string text = format("%s", countDown);
					const(char*) str = text.toStringz;
					float messageHeight = 50 + 50*interval + 50*(1-t);

					float halfMessageWidth = MFFont_GetStringWidth(arial, str, messageHeight, 0, -1, null) * 0.5;
					MFFont_DrawText2f(arial, orthoRect.width * 0.5 - halfMessageWidth, 250 - messageHeight*0.5, messageHeight, MFVector(1, t, 0, 1), str);
				}
				break;

			case Battle:
				if(roundLength - roundTimer < 2.5)
				{
					string battle = "Battle!";
					float halfMessageWidth = MFFont_GetStringWidth(arial, battle.ptr, 200, 0, -1, null) * 0.5;
					MFFont_DrawText2f(arial, orthoRect.width * 0.5 - halfMessageWidth, 250 - 100, 200, MFVector(1, 1, 0, 1), battle.ptr);
				}
				break;

			case PostRound:
				break;

			default:
		}
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

			arenaTag.onStartTag["properties"] = (ElementParser propertiesTag)
			{
				propertiesTag.onStartTag["dimensions"] = (ElementParser dimensionsTag)
				{
					dimensions.x = to!float(dimensionsTag.tag.attr["x"]);
					dimensions.z = to!float(dimensionsTag.tag.attr["z"]);

					dimensionsTag.parse();
				};

				propertiesTag.onStartTag["surfaces"] = (ElementParser surfacesTag)
				{
					surfacesTag.onStartTag["surface"] = &CreateSurface;

					surfacesTag.parse();
				};

				propertiesTag.onStartTag["sounds"] = (ElementParser soundTag)
				{
					string set = soundTag.tag.attr["file"];
					sounds = new SoundSet(set);

					soundTag.parse();
				};

				propertiesTag.onStartTag["music"] = (ElementParser musicTag)
				{
					string track = musicTag.tag.attr["track"];
					music = new Music(track);

					musicTag.parse();
				};

				propertiesTag.parse();
			};

			arenaTag.parse();
		};

		parser.parse();
	}

	void CreateSurface(ElementParser surfacesTag)
	{
		string type = surfacesTag.tag.attr["type"];
		string material = surfacesTag.tag.attr["material"];

		MaterialWrap newMat;
		newMat.mat = MFMaterial_Create(material.toStringz);

		materials[type] = newMat;
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
			if (cast(ICollider) entity !is null)
			{
				AddCollider(cast(ICollider) entity);
			}
		}

		return cast(IEntity) entity;
	}

	void AddEntity(IEntity entity)
	{
		resetEvent.subscribe(&entity.OnReset);

		if (entity.CanUpdate)
		{
			updateEvent.subscribe(&entity.OnUpdate);
			postUpdateEvent.subscribe(&entity.OnPostUpdate);
		}

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

	void AddCollider(ICollider collider)
	{
		colliders ~= collider;
		collision.AddCollider(collider);
	}

	private VoidEvent resetEvent;

	private VoidEvent thinkEvent;
	private VoidEvent updateEvent;
	private VoidEvent postUpdateEvent;

	private VoidEvent renderWorldEvent;
	private MFRectEvent renderGUIEvent;

	private VoidEvent roundBeginEvent;
	private VoidEvent roundEndEvent;

	private IEntity[] entities;
	private IThinker[] thinkers;
	private ICollider[] colliders;

	private MFVector dimensions;

	struct MaterialWrap
	{
		MFMaterial* mat;
	}

	private MaterialWrap[string] materials;

	private CollisionManager collision;

	private Music music;
	private SoundSet sounds;

	private RoundState roundState;
	private float roundLength = 60;
	private float roundTimer;

	private MFFont* arial;
}
