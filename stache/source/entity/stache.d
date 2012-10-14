module stache.entity.stache;

public import stache.i.entity;

import stache.i.renderable;

import std.conv;

interface IStache
{
	@property float LightAttackStrength();
	@property float LightAttackHitTime();
	@property float LightAttackCooldown();

	@property float HeavyAttackStrength();
	@property float HeavyAttackHitTime();
	@property float HeavyAttackCooldown();

	@property float SpecialAttackStrength();
	@property float SpecialAttackHitTime();
	@property float SpecialAttackCooldown();
}

class StacheEntity : IEntity, IStache
{
	struct State
	{
		MFMatrix transform;
		MFVector prevPosition;
	}

	/// IEntity
	void OnCreate(ElementParser element)
	{
		if (element !is null)
		{
			initialState.transform.t.x = 0.0; //to!float(element.tag.attr["x"]);
			initialState.transform.t.y = 0.0;
			initialState.transform.t.z = 0.0; //to!float(element.tag.attr["z"]);

			name = element.tag.attr["name"];
		}
	}

	void OnResolve(IEntity[string] loadedEntities)
	{
	}

	void OnReset()
	{
		state = initialState;
	}

	void OnDestroy()
	{
	}

	// Do movement and other type logic in this one
	void OnUpdate()
	{
	}

	// Need to resolve post-movement collisions, such as punching someone? Here's the place to do it.
	void OnPostUpdate()
	{
	}

	@property bool CanUpdate()			{ return true; }
	@property MFMatrix Transform()		{ return state.transform; }
	@property string Name()				{ return name; }

	private string name;

	private State	initialState,
					state;

	/// IRenderable
	void OnRenderWorld()
	{
	}

	void OnRenderGUI(MFRect orthoRect)
	{
	}

	@property bool CanRenderWorld()		{ return true; }
	@property bool CanRenderGUI()		{ return false; }

	/// IStache

	@property float LightAttackStrength()	{ return 0.0; }
	@property float LightAttackHitTime()	{ return 0.0; }
	@property float LightAttackCooldown()	{ return 0.0; }

	@property float HeavyAttackStrength()	{ return 0.0; }
	@property float HeavyAttackHitTime()	{ return 0.0; }
	@property float HeavyAttackCooldown()	{ return 0.0; }

	@property float SpecialAttackStrength()	{ return 0.0; }
	@property float SpecialAttackHitTime()	{ return 0.0; }
	@property float SpecialAttackCooldown()	{ return 0.0; }
}
