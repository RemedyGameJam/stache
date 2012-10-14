module stache.entity.stache;

public import stache.i.entity;

import fuji.model;

import stache.i.renderable;

import std.conv;

interface IStache
{
	void OnResolveAttach(IEntity entity);
	void OnAttach(IEntity entity);
	void OnDetach(IEntity entity);

	@property string ModelFilename();

	@property float LightAttackStrength();
	@property float LightAttackBackStrength();
	@property float LightAttackHitTime();
	@property float LightAttackCooldown();

	@property float HeavyAttackStrength();
	@property float HeavyAttackBackStrength();
	@property float HeavyAttackHitTime();
	@property float HeavyAttackCooldown();

	@property float SpecialAttackStrength();
	@property float SpecialAttackBackStrength();
	@property float SpecialAttackHitTime();
	@property float SpecialAttackCooldown();
}

class StacheEntity : IEntity, IStache, IRenderable
{
	struct State
	{
		MFMatrix transform;
		MFVector prevPosition;
		IEntity attachedTo = null;
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

		model = MFModel_Create(ModelFilename.ptr);
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
		MFModel_Destroy(model);
	}

	// Do movement and other type logic in this one
	void OnUpdate()
	{
	}

	// Need to resolve post-movement collisions, such as punching someone? Here's the place to do it.
	void OnPostUpdate()
	{
	}

	@property bool CanUpdate()					{ return true; }
	@property MFMatrix Transform()				{ return state.transform; }
	@property MFMatrix Transform(MFMatrix t)
	{
		state.transform = t;
		MFModel_SetWorldMatrix(model, state.transform);

		return state.transform ;
	}
	@property string Name()						{ return name; }

	private string name;

	private State	initialState,
					state;

	/// IRenderable
	void OnRenderWorld()
	{
		if (state.attachedTo !is null)
			MFModel_Draw(model);
	}

	void OnRenderGUI(MFRect orthoRect)
	{
	}

	@property bool CanRenderWorld()				{ return true; }
	@property bool CanRenderGUI()				{ return false; }

	private MFModel* model;


	/// IStache

	void OnResolveAttach(IEntity entity)
	{
		initialState.attachedTo = entity;
	}

	void OnAttach(IEntity entity)
	{
		state.attachedTo = entity;
	}

	void OnDetach(IEntity entity)
	{
		if (state.attachedTo == entity)
			state.attachedTo = null;
	}


	@property string ModelFilename()			{ return "shitkicker"; }

	@property float LightAttackStrength()		{ return 0.0; }
	@property float LightAttackBackStrength()	{ return LightAttackStrength; }
	@property float LightAttackHitTime()		{ return 0.0; }
	@property float LightAttackCooldown()		{ return 0.0; }

	@property float HeavyAttackStrength()		{ return 0.0; }
	@property float HeavyAttackBackStrength()	{ return HeavyAttackStrength; }
	@property float HeavyAttackHitTime()		{ return 0.0; }
	@property float HeavyAttackCooldown()		{ return 0.0; }

	@property float SpecialAttackStrength()		{ return 0.0; }
	@property float SpecialAttackBackStrength()	{ return SpecialAttackStrength; }
	@property float SpecialAttackHitTime()		{ return 0.0; }
	@property float SpecialAttackCooldown()		{ return 0.0; }
}
