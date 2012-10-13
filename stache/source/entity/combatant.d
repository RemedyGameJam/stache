module stache.entity.combatant;

import fuji.vector;

import stache.i.thinker;
import stache.i.entity;
import stache.i.renderable;

class Combatant : ISheeple, IEntity, IRenderable
{
	/// IEntity
	void OnCreate()
	{
	}

	void OnDestroy()
	{
	}

	void OnLoadDone()
	{
	}

	void OnUpdate()
	{
	}

	@property bool CanUpdate() { return true; }

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
	}

	@property bool CanMove() { return true; }
	@property bool CanAttack() { return true; }
	@property bool CanBlock() { return true; }

	@property int Health() { return 100; }

	@property bool IsAttacking() { return false; }
	@property bool IsBlocking() { return false; }


	///IRenderable
	void OnRenderWorld()
	{
	}

	void OnRenderGUI(MFRect orthoRect)
	{
	}

	@property bool CanRenderWorld() { return true; }
	@property bool CanRenderGUI() { return false; }

}
