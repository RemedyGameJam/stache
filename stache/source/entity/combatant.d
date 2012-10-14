module stache.entity.combatant;

import stache.sound.soundset;

import fuji.system;
import fuji.vector;
import fuji.material;
import fuji.primitive;
import fuji.model;

import stache.i.thinker;
import stache.i.entity;
import stache.i.renderable;
import stache.i.collider;

import stache.entity.stache;

import std.conv;
import std.string;
import std.math;

enum CombatantDirection
{
	Left,
	Right,
}

class Combatant : ISheeple, IEntity, IRenderable, ICollider
{
	const int DefaultHealth = 100;
	const float DefaultMoveSpeed = 15;
	const float DefaultMoveSpeedRunModifier = 1.65;

	struct State
	{
		MFMatrix transform;
		MFVector prevPosition;
		int health = DefaultHealth;
		CombatantDirection facing = CombatantDirection.Left;
		ISheeple.Moves activeMoves = ISheeple.Moves.None;
		IStache stache = null;
	}

	/// IEntity
	void OnCreate(ElementParser element)
	{
		if (element !is null)
		{
			initialState.transform.x = MFVector.right * -0.01;
			initialState.transform.y = MFVector.up * 0.01;
			initialState.transform.z = MFVector.forward * -0.01;

			initialState.transform.t.x = to!float(element.tag.attr["x"]);
			initialState.transform.t.y = 0.0; //CollisionParameters.y;
			initialState.transform.t.z = to!float(element.tag.attr["z"]);

			string facingVal = element.tag.attr["facing"];
			foreach(m; __traits(allMembers, CombatantDirection))
			{
				if (toLower(m) == toLower(facingVal))
				{
					initialState.facing = mixin("CombatantDirection." ~ m);
					break;
				}
			}

			initialState.prevPosition = initialState.transform.t;

			name = element.tag.attr["name"];
		}

		mattDamon = MFMaterial_Create("MattDamon");

		model = MFModel_Create("Hogan_walk_static");

		soundSet = new SoundSet("s1");
	}

	void OnReset()
	{
		state = initialState;
		UpdateFacing();
	}

	void OnDestroy()
	{
		MFModel_Destroy(model);
		MFMaterial_Destroy(mattDamon);
	}

	void OnUpdate()
	{
		PrevPosition = Position;
		Position = Position + moveDirection * MFSystem_GetTimeDelta();

		if (moveDirection.magSq3() > 0)
		{
			if (moveDirection.x >= 0)
				state.facing = CombatantDirection.Right;
			else
				state.facing = CombatantDirection.Left;

			UpdateFacing();
		}
	}

	private void UpdateFacing()
	{
		float angle = MFDeg2Rad!60;
		if (state.facing == CombatantDirection.Left)
			angle *= -1;

		MFVector normalisedDir;
		normalisedDir.x = sin(angle);
		normalisedDir.z = -cos(angle);

//		MFVector normalisedDir = normalise(moveDirection);

		state.transform.x = cross3(MFVector.up, normalisedDir) * -0.01;
		state.transform.y = MFVector.up * 0.01;
		state.transform.z = normalisedDir * -0.01;
	}

	void OnPostUpdate()
	{
		MFModel_SetWorldMatrix(model, state.transform);

		if ((ActiveMoves & ISheeple.Moves.AllAttacks) != ISheeple.Moves.None)
		{
			MFVector attackPos = Transform.t;
			if (Facing == CombatantDirection.Left)
				attackPos.x -= CollisionParameters.x;
			else
				attackPos.x += CollisionParameters.x;

			ICollider[] found = colMan.FindCollisionSphere(attackPos, 0.5, CollisionClass.Combatant, cast(ICollider) this);

			foreach(collider; found)
			{
				int foo = 1;
			}

			ActiveMoves = ActiveMoves & ~ISheeple.Moves.AllAttacks;
		}
	}

	@property bool CanUpdate() { return true; }
	@property MFMatrix Transform() { return state.transform; }
	@property string Name() { return name; }

	private @property Position() { return state.transform.t; }
	private @property Position(MFVector newPos) { return (state.transform.t = newPos); }
	private @property PrevPosition() { return state.prevPosition; }
	private @property PrevPosition(MFVector newPrevPos) { return state.prevPosition; }
	private @property Facing() { return state.facing; }

	private @property ActiveMoves() { return state.activeMoves; }
	private @property ActiveMoves(ISheeple.Moves newMoves) { return (state.activeMoves = newMoves); }

	private @property ValidStache() { return state.stache !is null; }

	private State				initialState,
								state;

	private string				name;

	/// ISheeple

	void OnLightAttack()
	{
		if (ValidStache)
			ActiveMoves = ActiveMoves | ISheeple.Moves.LightAttack;
		if(soundSet)
			soundSet.Play("light");
	}

	void OnHeavyAttack()
	{
		if (ValidStache)
			ActiveMoves = ActiveMoves | ISheeple.Moves.HeavyAttack;
		if(soundSet)
			soundSet.Play("heavy");
	}

	void OnSpecialAttack()
	{
		if (ValidStache)
			ActiveMoves = ActiveMoves | ISheeple.Moves.SpecialAttack;
		if(soundSet)
			soundSet.Play("special");
	}

	void OnBlock()
	{
	}

	void OnUnblock()
	{
	}

	void OnMove(MFVector direction)
	{
		moveDirection = direction * MoveSpeed;
	}
	
	void OnReceiveAttack(Moves type, float strength)
	{
	}

	@property bool CanMove() { return true; }
	@property bool CanAttack() { return true; }
	@property bool CanBlock() { return true; }

	@property int Health() { return state.health; }

	@property bool IsAttacking() { return false; }
	@property bool IsBlocking() { return false; }
	@property bool IsRunning() { return false; }

	private @property float MoveSpeed() { return DefaultMoveSpeed * (IsRunning ? DefaultMoveSpeedRunModifier : 1); }

	MFVector moveDirection;

	///IRenderable
	void OnRenderWorld()
	{
		MFPrimitive_DrawSphere(Transform.t, CollisionParameters.x, 8, 5, MFVector.one, MFMatrix.identity, true);
		MFModel_Draw(model);
	}

/*	void OnRenderWorld()
	{
		MFMaterial_SetMaterial(mattDamon);

		MFPrimitive(PrimType.TriStrip | PrimType.Prelit, 0);
		MFSetMatrix(state.transform);
		MFBegin(4);
		{
			MFSetTexCoord1(0, 1);
			MFSetPosition(-0.5, -0.5, 0);

			MFSetTexCoord1(0, 0);
			MFSetPosition(-0.5, 0.5, 0);

			MFSetTexCoord1(1, 1);
			MFSetPosition(0.5, -0.5, 0);

			MFSetTexCoord1(1, 0);
			MFSetPosition(0.5, 0.5, 0);
		}
		MFEnd();
	}*/

	void OnRenderGUI(MFRect orthoRect)
	{
	}

	@property bool CanRenderWorld() { return true; }
	@property bool CanRenderGUI() { return false; }

	/// ICollider
	void OnAddCollision(CollisionManager owner)
	{
		colMan = owner;
	}

	@property MFVector CollisionPosition() { return state.transform.t; }
	@property MFVector CollisionPosition(MFVector pos)
	{
		state.transform.t = pos;
		// Do extra stuff;
		return state.transform.t;
	}

	@property MFVector CollisionPrevPosition() { return state.prevPosition; }

	@property CollisionType CollisionTypeEnum() { return CollisionType.Sphere; }
	@property CollisionClass CollisionClassEnum() { return CollisionClass.Combatant; }
	@property MFVector CollisionParameters() { return MFVector(1.3, 1.3, 1.3, 1.3); } // { return MFVector(0.51, 0.51, 0.51, 0.51); }

	CollisionManager colMan;

	MFMaterial* mattDamon;
	MFModel* model;

	SoundSet soundSet;
}
