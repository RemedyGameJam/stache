module stache.entity.combatant;

import stache.sound.soundset;

import fuji.system;
import fuji.vector;
import fuji.material;
import fuji.primitive;

import stache.i.thinker;
import stache.i.entity;
import stache.i.renderable;
import stache.i.collider;

import stache.entity.stache;

import std.conv;
import std.string;
import std.math;
import std.algorithm;

enum CombatantDirection
{
	Left,
	Right,
}

class Combatant : ISheeple, IEntity, IRenderable, ICollider
{
	const float DefaultHealth = 100;
	const float DefaultMoveSpeed = 15;
	const float DefaultMoveSpeedRunModifier = 1.65;

	struct State
	{
		MFMatrix transform;
		MFVector prevPosition;
		float healthMax = DefaultHealth;
		float health = DefaultHealth;
		CombatantDirection facing = CombatantDirection.Left;
		StacheEntity stache = null;
		float damageDealt = 0;

		ISheeple.Moves activeMoves = ISheeple.Moves.None;
		float attackStrength = 0.0;
		float attackBackStrength = 0.0;
		float attackTimeTillHit = 0.0;
		float attackTimeCooldown = 0.0;
		string attackAnim;
	}

	/// IEntity
	void OnCreate(ElementParser element)
	{
		if (element !is null)
		{
			initialState.transform.x = MFVector.right * -1;
			initialState.transform.y = MFVector.up;
			initialState.transform.z = MFVector.forward * -1;

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
			defaultStache = element.tag.attr["defaultstache"];
		}

		mattDamon = MFMaterial_Create("MattDamon");
	}

	void OnResolve(IEntity[string] loadedEntities)
	{
		if (loadedEntities is null)
			return;

		IEntity* ent = defaultStache in loadedEntities;
		if (!ent)
			return;

		StacheEntity stache = cast(StacheEntity) *ent;

		if (stache !is null)
		{
			initialState.stache = stache;
			stache.OnResolveAttach(this);
		}
		else
		{
			// TODO: stuff
		}
	}

	void OnReset()
	{
		state = initialState;
		UpdateFacing();
	}

	void OnDestroy()
	{
		MFMaterial_Destroy(mattDamon);
	}

	void OnUpdate()
	{
		if (!Alive)
			return;

		if (!ActiveMoves)
		{
			PrevPosition = Position;
			Position = Position + moveDirection * MFSystem_GetTimeDelta();
		}

		if (moveDirection.magSq3() > 0)
		{
			if (moveDirection.x >= 0)
				state.facing = CombatantDirection.Right;
			else
				state.facing = CombatantDirection.Left;

			UpdateFacing();

			moveDirection *= 0.75;

			if (moveDirection.magSq3() < 0.01 * 0.01)
			{
				moveDirection = MFVector.zero;
				if (ValidStache && !ActiveAttacks)
					Stache.SetAnimation("idle");
			}

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

		state.transform.x = cross3(MFVector.up, normalisedDir) * -1;
		state.transform.y = MFVector.up * 1;
		state.transform.z = normalisedDir * -1;
	}

	void OnPostUpdate()
	{
		if (!Alive)
		{
			if (ValidStache)
				Stache.Transform = Transform;
			return;
		}

		if ((ActiveMoves & ISheeple.Moves.AllAttacks) != ISheeple.Moves.None)
		{
			if (AttackTimeTillHit > 0)
			{
				AttackTimeTillHit = max(0, AttackTimeTillHit - MFSystem_GetTimeDelta());
				if (AttackTimeTillHit <= 0)
				{
					MFVector attackPos = Transform.t;
					if (Facing == CombatantDirection.Left)
						attackPos.x -= CollisionParameters.x;
					else
						attackPos.x += CollisionParameters.x;

					ICollider[] found = colMan.FindCollisionSphere(attackPos, 0.5, CollisionClass.Combatant, cast(ICollider) this);

					foreach(collider; found)
					{
						Combatant c = cast(Combatant) collider;
						if (found !is null)
						{
							float strength = AttackStrength;
							if (Facing == c.Facing)
								strength = AttackBackStrength;

							if (Facing == c.Facing || !c.IsBlocking)
							{
								float damageDealt = c.OnReceiveAttack(ActiveAttacks, strength);

								state.damageDealt += damageDealt;
							}
						}
					}

					if (ValidStache)
						Stache.SetAnimation(state.attackAnim);
				}
			}
			else if (AttackTimeCooldown > 0)
			{
				AttackTimeCooldown = max(0, AttackTimeCooldown - MFSystem_GetTimeDelta());
				if (AttackTimeCooldown <= 0)
				{
					ActiveMoves = ActiveMoves & ~ISheeple.Moves.AllAttacks;
					if (ValidStache)
						Stache.SetAnimation("idle");
				}
			}
			else
			{
				ActiveMoves = ActiveMoves & ~ISheeple.Moves.AllAttacks;

				if (ValidStache)
					Stache.SetAnimation("idle");
			}
		}

		if (ValidStache)
			Stache.Transform = Transform;
	}

	@property bool CanUpdate() { return true; }
	@property MFMatrix Transform() { return state.transform; }
	@property MFMatrix Transform(MFMatrix t)	{ return (state.transform = t); }
	@property string Name() { return name; }

	@property string CharacterName() { if (ValidStache) return Stache.CharacterName; return Name; }
	@property MFMaterial* Portrait() { if (ValidStache) return Stache.Portrait; return null; }

	private @property Position() { return state.transform.t; }
	private @property Position(MFVector newPos) { return (state.transform.t = newPos); }
	private @property PrevPosition() { return state.prevPosition; }
	private @property PrevPosition(MFVector newPrevPos) { return state.prevPosition; }
	private @property Facing() { return state.facing; }

	private @property ActiveMoves() { return state.activeMoves; }
	private @property ActiveAttacks() { return (state.activeMoves & ISheeple.Moves.AllAttacks); }
	private @property ActiveMoves(ISheeple.Moves newMoves) { return (state.activeMoves = newMoves); }

	private @property AttackStrength()				{ return state.attackStrength; }
	private @property AttackStrength(float s)		{ return (state.attackStrength = s); }

	private @property AttackBackStrength()			{ return state.attackBackStrength; }
	private @property AttackBackStrength(float s)	{ return (state.attackBackStrength = s); }

	private @property AttackTimeTillHit()			{ return state.attackTimeTillHit; }
	private @property AttackTimeTillHit(float t)	{ return (state.attackTimeTillHit = t); }

	private @property AttackTimeCooldown()			{ return state.attackTimeCooldown; }
	private @property AttackTimeCooldown(float t)	{ return (state.attackTimeCooldown = t); }

	private @property ValidStache() { return state.stache !is null; }
	private @property Stache() { return state.stache; }

	private State				initialState,
								state;

	private string				name;
	private string				defaultStache;

	private MFMaterial*			portrait;

	/// ISheeple

	void OnLightAttack()
	{
		if (!Alive)
			return;

		if (!ActiveAttacks)
		{
			if (ValidStache)
			{
				ActiveMoves = ActiveMoves | ISheeple.Moves.LightAttack;
				AttackStrength = Stache.LightAttackStrength;
				AttackBackStrength = Stache.LightAttackBackStrength;
				AttackTimeTillHit = Stache.LightAttackHitTime;
				AttackTimeCooldown = Stache.LightAttackCooldown;

				Stache.PlaySound("light");
				Stache.SetAnimation("light_wind");
				state.attackAnim = "light_blow";
			}
		}
	}

	void OnHeavyAttack()
	{
		if (!Alive)
			return;

		if (!ActiveAttacks)
		{
			if (ValidStache)
			{
				ActiveMoves = ActiveMoves | ISheeple.Moves.HeavyAttack;
				AttackStrength = Stache.HeavyAttackStrength;
				AttackBackStrength = Stache.HeavyAttackBackStrength;
				AttackTimeTillHit = Stache.HeavyAttackHitTime;
				AttackTimeCooldown = Stache.HeavyAttackCooldown;

				Stache.PlaySound("heavy");
				Stache.SetAnimation("heavy_wind");
				state.attackAnim = "heavy_blow";
			}
		}
	}

	void OnSpecialAttack()
	{
		if (!Alive)
			return;

		if (!ActiveAttacks)
		{
			if (ValidStache)
			{
				ActiveMoves = ActiveMoves | ISheeple.Moves.SpecialAttack;
				AttackStrength = Stache.SpecialAttackStrength;
				AttackBackStrength = Stache.SpecialAttackBackStrength;
				AttackTimeTillHit = Stache.SpecialAttackHitTime;
				AttackTimeCooldown = Stache.SpecialAttackCooldown;

				Stache.PlaySound("special");
				Stache.SetAnimation("special_wind");
				state.attackAnim = "special_blow";
			}
		}
	}

	void OnBlock()
	{
		if (!Alive)
			return;

		if (ActiveAttacks)
			return;

		ActiveMoves = ActiveMoves | ISheeple.Moves.Block;

		if (ValidStache)
			Stache.SetAnimation("idle");
	}

	void OnUnblock()
	{
		if (!Alive)
			return;

		ActiveMoves = ActiveMoves & ~ISheeple.Moves.Block;

		if (moveDirection.magSq3() > 0)
			Stache.SetAnimation("walk");
	}

	void OnMove(MFVector direction)
	{
		if (!Alive)
			return;

		if (!ActiveAttacks)
		{
			float lastMoveMag = moveDirection.mag3();

			moveDirection = direction * MoveSpeed;

			if (!IsBlocking() && ValidStache && lastMoveMag <= 0 && moveDirection.mag3() > 0.01)
				Stache.SetAnimation("walk");
		}
	}
	
	float OnReceiveAttack(Moves type, float strength)
	{
		float prevHealth = state.health;

		state.health = max(0, state.health - strength);

		if(ValidStache)
			Stache.PlaySound("hit");

		if (!Alive)
		{
			Stache.SetAnimation("death");
			ActiveMoves = ISheeple.Moves.None;
		}

		return prevHealth - state.health;
	}

	@property bool CanMove() { return true; }
	@property bool CanAttack() { return true; }
	@property bool CanBlock() { return true; }

	@property float Health() { return state.health / state.healthMax; }
	@property float DamageDealt() { return state.damageDealt; }
	@property bool Alive() { return Health > 0; }

	@property bool IsAttacking() { return (ActiveAttacks & ISheeple.Moves.AllAttacks) != 0; }
	@property bool IsBlocking() { return !IsAttacking && (ActiveMoves & ISheeple.Moves.Block) != ISheeple.Moves.None; }
	@property bool IsRunning() { return false; }

	private @property float MoveSpeed() { return DefaultMoveSpeed * (IsRunning ? DefaultMoveSpeedRunModifier : 1); }

	MFVector moveDirection;

	///IRenderable
	void OnRenderWorld()
	{
/*		if (CollisionTypeEnum == CollisionType.Sphere)
		{
			MFPrimitive_DrawSphere(Transform.t, CollisionParameters.x, 8, 5, MFVector.one, MFMatrix.identity, true);
		}
		else if (CollisionTypeEnum == CollisionType.Box)
		{
			MFVector	boxMin = Transform.t - CollisionParameters,
						boxMax = Transform.t + CollisionParameters;

			MFPrimitive_DrawBox(boxMin, boxMax, MFVector.one, MFMatrix.identity, true);
		}*/

		if (IsBlocking)
		{
			MFMaterial_SetMaterial(mattDamon);

			MFPrimitive(PrimType.TriList | PrimType.Prelit, 0);

			MFMatrix shieldTransform = state.transform;
			shieldTransform.x *= 3;
			shieldTransform.y *= 3;
			shieldTransform.z *= 3;
			shieldTransform.t += shieldTransform.z * (-CollisionParameters.z * 0.5);

			shieldTransform.t.y += CollisionParameters.y;

			MFSetMatrix(shieldTransform);
			MFBegin(18);
			{
				// Left seg
				MFSetTexCoord1(0, 1);
				MFSetPosition(-0.5, -0.5, 0.25);

				MFSetTexCoord1(0, 0);
				MFSetPosition(-0.5, 0.5, 0.25);

				MFSetTexCoord1(0.25, 1);
				MFSetPosition(-0.25, -0.5, 0);


				MFSetTexCoord1(0, 0);
				MFSetPosition(-0.5, 0.5, 0.25);

				MFSetTexCoord1(0.25, 0);
				MFSetPosition(-0.25, 0.5, 0);

				MFSetTexCoord1(0.25, 1);
				MFSetPosition(-0.25, -0.5, 0);


				// Middle seg
				MFSetTexCoord1(0.25, 1);
				MFSetPosition(-0.25, -0.5, 0);

				MFSetTexCoord1(0.25, 0);
				MFSetPosition(-0.25, 0.5, 0);

				MFSetTexCoord1(0.75, 1);
				MFSetPosition(0.25, -0.5, 0);


				MFSetTexCoord1(0.25, 0);
				MFSetPosition(-0.25, 0.5, 0);

				MFSetTexCoord1(0.75, 0);
				MFSetPosition(0.25, 0.5, 0);

				MFSetTexCoord1(0.75, 1);
				MFSetPosition(0.25, -0.5, 0);


				// Right seg
				MFSetTexCoord1(0.75, 1);
				MFSetPosition(0.25, -0.5, 0);

				MFSetTexCoord1(0.75, 0);
				MFSetPosition(0.25, 0.5, 0);

				MFSetTexCoord1(1, 1);
				MFSetPosition(0.5, -0.5, 0.25);


				MFSetTexCoord1(0.75, 0);
				MFSetPosition(0.25, 0.5, 0);

				MFSetTexCoord1(1, 0);
				MFSetPosition(0.5, 0.5, 0.25);

				MFSetTexCoord1(1, 1);
				MFSetPosition(0.5, -0.5, 0.25);
			}
			MFEnd();
		}
	}

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

	@property CollisionType CollisionTypeEnum() { return CollisionType.Box; }
	@property CollisionClass CollisionClassEnum() { return CollisionClass.Combatant; }
	@property MFVector CollisionParameters() { return MFVector(1.3, 1.3, 1, 0); } // { return MFVector(0.51, 0.51, 0.51, 0.51); }

	CollisionManager colMan;

	MFMaterial* mattDamon;
}
