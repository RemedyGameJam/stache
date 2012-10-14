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

import stache.battlecamera;

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
	BattleCamera camera;

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

		camera = new BattleCamera;

		chinese = MFFont_Create("ChineseRocks");

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

		resolveEvent(entities);

		postUpdateEvent.subscribe(&camera.OnPostUpdate);
		resetEvent.subscribe(&camera.OnReset);

		// Leaks like a bitch
		//MFHeap_Free(rawData);


		roundState = RoundState.WaitForTwo;
		stateTimer = 2;
		roundTimer = roundLength;

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

		camera = null;
		collision = null;
	}

	void OnUpdate()
	{
		final switch(roundState) with(RoundState)
		{
			case WaitForTwo:
				stateTimer -= 1;
				if(stateTimer <= 0)
				{
					// begin pre-round countdown
					roundState = RoundState.PreRound;
					stateTimer = 5;
				}
				break;
			case PreRound:
				stateTimer -= MFSystem_GetTimeDelta();

				if(stateTimer <= 0)
				{
					roundState = Battle;
					roundBeginEvent();
				}
				break;

			case Battle:
				roundTimer -= MFSystem_GetTimeDelta();

				if(roundTimer < 0)
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
			camera.Apply();

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

		RenderLifeBars(orthoRect);

		switch(roundState) with(RoundState)
		{
			case PreRound:
				RenderTime(orthoRect);

				if(stateTimer < 3)
				{
					int countDown = cast(int)(stateTimer + 1);
					float interval = stateTimer - cast(int)stateTimer;
					float t = stateTimer / 3;

					string text = format("%s", countDown);
					const(char*) str = text.toStringz;
					float messageHeight = 50 + 150*interval + 200*(1-t);

					float halfMessageWidth = MFFont_GetStringWidth(chinese, str, messageHeight, 0, -1, null) * 0.5;
					MFFont_DrawText2f(chinese, orthoRect.width * 0.5 - halfMessageWidth, 250 - messageHeight*0.5, messageHeight, MFVector(1, t, 0, 1), str);
				}
				break;

			case Battle:
				RenderTime(orthoRect);

				if(roundLength - roundTimer < 2.5)
				{
					string battle = "Battle!";
					float halfMessageWidth = MFFont_GetStringWidth(chinese, battle.ptr, 200, 0, -1, null) * 0.5;
					MFFont_DrawText2f(chinese, orthoRect.width * 0.5 - halfMessageWidth, 250 - 100, 200, MFVector.white, battle.ptr);
				}
				break;

			case PostRound:
				break;

			default:
		}
	}

	void RenderTime(MFRect orthoRect)
	{
		int countDown = cast(int)(roundTimer + 1);
		string text = format("%s", countDown);
		const(char*) str = text.toStringz;

		float messageHeight = 80;

		float halfMessageWidth = MFFont_GetStringWidth(chinese, str, messageHeight, 0, -1, null) * 0.5;
		MFFont_DrawText2f(chinese, orthoRect.width * 0.5 - halfMessageWidth, 50 - messageHeight*0.5, messageHeight, MFVector.white, str);
	}

	void RenderLifeBars(MFRect orthoRect)
	{
		float hScreen = orthoRect.width*0.5;
		float qScreen = hScreen*0.5 * 0.9;

		MFRect player0 = MFRect(qScreen - 80 - hScreen*0.3,						20, hScreen*0.6, 80);
		MFRect player1 = MFRect(orthoRect.width - qScreen + 80 - hScreen*0.3,	20, hScreen*0.6, 80);
		MFRect player2 = MFRect(qScreen + 80 - hScreen*0.3,						80, hScreen*0.6, 80);
		MFRect player3 = MFRect(orthoRect.width - qScreen - 80 - hScreen*0.3,	80, hScreen*0.6, 80);

		RenderLifeBar(orthoRect, player0, false, combatants[0].Health);
		RenderLifeBar(orthoRect, player1, true, combatants[1].Health);
		RenderLifeBar(orthoRect, player2, true, combatants[2].Health);
		RenderLifeBar(orthoRect, player3, false, combatants[3].Health);
	}

	void RenderLifeBar(MFRect orthoRect, MFRect r, bool bPortraitOnRight, float health)
	{
		float portraitWidth = r.height;
		float barWidth = r.width - portraitWidth;

		float barHeight = 40;
		float barTop = r.height*0.5 - barHeight*0.5;

		if(bPortraitOnRight)
		{
			// draw portrait
			MFPrimitive_DrawUntexturedQuad(r.x + r.width - portraitWidth, r.y, portraitWidth, r.height, MFVector.one, MFMatrix.identity);
			MFPrimitive_DrawUntexturedQuad(r.x + r.width - portraitWidth + 4, r.y + 4, portraitWidth - 8, r.height - 8, MFVector.black, MFMatrix.identity);

			// draw lifeBar
			MFPrimitive_DrawUntexturedQuad(r.x - 2, r.y + barTop - 2, r.width - portraitWidth + 4, barHeight + 4, MFVector.one, MFMatrix.identity);
			MFPrimitive_DrawUntexturedQuad(r.x + (r.width - portraitWidth)*(1 - health), r.y + barTop, (r.width - portraitWidth)*health, barHeight, MFVector.red, MFMatrix.identity);
		}
		else
		{
			// draw portrait
			MFPrimitive_DrawUntexturedQuad(r.x, r.y, portraitWidth, r.height, MFVector.one, MFMatrix.identity);
			MFPrimitive_DrawUntexturedQuad(r.x + 4, r.y + 4, portraitWidth - 8, r.height - 8, MFVector.black, MFMatrix.identity);

			// draw lifeBar
			MFPrimitive_DrawUntexturedQuad(r.x + portraitWidth - 2, r.y + barTop - 2, r.width - portraitWidth + 4, barHeight + 4, MFVector.one, MFMatrix.identity);
			MFPrimitive_DrawUntexturedQuad(r.x + portraitWidth, r.y + barTop, (r.width - portraitWidth) * health, barHeight, MFVector.red, MFMatrix.identity);
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

			return actualEntity;
		}

		return null;
	}

	void AddEntity(IEntity entity)
	{
		resolveEvent.subscribe(&entity.OnResolve);
		resetEvent.subscribe(&entity.OnReset);

		if (entity.CanUpdate)
		{
			updateEvent.subscribe(&entity.OnUpdate);
			postUpdateEvent.subscribe(&entity.OnPostUpdate);
		}

		entities[entity.Name] = entity;
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
		combatants ~= combatant;

		camera.AddTrackedEntity(combatant);
	}

	void AddCollider(ICollider collider)
	{
		colliders ~= collider;
		collision.AddCollider(collider);
	}

	private IEntityMapEvent resolveEvent;

	private VoidEvent resetEvent;

	private VoidEvent thinkEvent;
	private VoidEvent updateEvent;
	private VoidEvent postUpdateEvent;

	private VoidEvent renderWorldEvent;
	private MFRectEvent renderGUIEvent;

	private VoidEvent roundBeginEvent;
	private VoidEvent roundEndEvent;

	private IEntity[string] entities;
	private IThinker[] thinkers;
	private ICollider[] colliders;
	private Combatant[] combatants;

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
	private float stateTimer;
	private float roundLength = 89.99999;
	private float roundTimer;

	private MFFont* chinese;
}
