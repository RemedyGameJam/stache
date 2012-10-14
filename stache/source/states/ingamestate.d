module stache.states.ingamestate;

import fuji.filesystem;
import fuji.render;
import fuji.matrix;
import fuji.material;
import fuji.primitive;

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

class InGameState : IState
{
	BattleCamera camera;

	void OnAdd(StateMachine statemachine)
	{
		owner = statemachine;
	}

	void OnEnter()
	{
		collision = new CollisionManager;

		camera = new BattleCamera;

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

		postUpdateEvent.subscribe(&camera.OnPostUpdate);
		resetEvent.subscribe(&camera.OnReset);

		// Leaks like a bitch
		//MFHeap_Free(rawData);

		resetEvent();
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
		thinkEvent();

		updateEvent();
		collision.OnUpdate();
		postUpdateEvent();
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

		camera.AddTrackedEntity(combatant);
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
}
