module stache.entity.combatant;

import fuji.system;
import fuji.vector;
import fuji.material;
import fuji.primitive;

import stache.i.thinker;
import stache.i.entity;
import stache.i.renderable;

import std.conv;

class Combatant : ISheeple, IEntity, IRenderable
{
	const int DefaultHealth = 100;
	const float DefaultMoveSpeed = 15;
	const float DefaultMoveSpeedRunModifier = 1.65;

	struct State
	{
		MFMatrix transform;
		int health = DefaultHealth;
	}

	/// IEntity
	void OnCreate(ElementParser element)
	{
		if (element !is null)
		{
			initialState.transform.t.x = to!float(element.tag.attr["x"]);
			initialState.transform.t.z = to!float(element.tag.attr["z"]);

			name = element.tag.attr["name"];
		}

		mattDamon = MFMaterial_Create("MattDamon");
	}

	void OnReset()
	{
		state = initialState;
	}

	void OnDestroy()
	{
	}

	void OnUpdate()
	{
		Position = Position + moveDirection * MFSystem_GetTimeDelta();
	}

	@property bool CanUpdate() { return true; }
	@property MFMatrix Transform() { return state.transform; }
	@property string Name() { return name; }

	private @property Position() { return state.transform.t; }
	private @property Position(MFVector newPos) { return (state.transform.t = newPos); }

	private State	initialState,
					state;

	private string	name;

	/// IThinker
	void OnLightAttack()
	{
	}

	void OnHeavyAttack()
	{
	}

	void OnSpecialAttack()
	{
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
	}

	void OnRenderGUI(MFRect orthoRect)
	{
	}

	@property bool CanRenderWorld() { return true; }
	@property bool CanRenderGUI() { return false; }

	MFMaterial* mattDamon;
}
