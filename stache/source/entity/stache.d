module stache.entity.stache;

public import stache.i.entity;

import fuji.model;

import stache.sound.soundset;

import stache.i.renderable;
import stache.util.meshanimator;

import std.conv;

interface IStache
{
	void OnResolveAttach(IEntity entity);
	void OnAttach(IEntity entity);
	void OnDetach(IEntity entity);

	@property string ModelFilename();
	@property string SoundsetFilename();

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

		animator = new MeshAnimator(ModelFilename);
		soundSet = new SoundSet(SoundsetFilename);
	}

	void OnResolve(IEntity[string] loadedEntities)
	{
	}

	void OnReset()
	{
		state = initialState;
		animator.OnReset();
	}

	void OnDestroy()
	{
		animator.OnDestroy();
		animator = null;
	}

	// Do movement and other type logic in this one
	void OnUpdate()
	{
		animator.OnUpdate();
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
		MFModel* mesh = animator.CurrentMesh;
		MFModel_SetWorldMatrix(mesh, state.transform);

		return state.transform;
	}
	@property string Name()						{ return name; }

	private string name;

	private State	initialState,
					state;

	/// IRenderable
	void OnRenderWorld()
	{
		MFModel* mesh = animator.CurrentMesh;
		if (state.attachedTo !is null)
			MFModel_Draw(mesh);
	}

	void OnRenderGUI(MFRect orthoRect)
	{
	}

	@property bool CanRenderWorld()				{ return true; }
	@property bool CanRenderGUI()				{ return false; }


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
	@property string SoundsetFilename()			{ return "ballsucker"; }

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


	/// Special methods

	void SetAnimation(string animName) { if (animator !is null) animator.SetAnimation(animName); }
	void PlaySound(string animName) { if (soundSet !is null) soundSet.Play(animName); }

	private MeshAnimator animator;
	private SoundSet soundSet;

}
