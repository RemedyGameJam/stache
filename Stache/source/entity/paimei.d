module stache.entity.paimei;

public import stache.entity.stache;

class PaiMei : StacheEntity
{
	@property string ModelFilename()			{ return "paimei_anims.xml"; }
	@property string SoundsetFilename()			{ return "player2"; }

	/// IStache
	@property float LightAttackStrength()		{ return 9001; }
	@property float LightAttackBackStrength()	{ return 9001; }
	@property float LightAttackHitTime()		{ return 0.01; }
	@property float LightAttackCooldown()		{ return 0.01; }

	@property float HeavyAttackStrength()		{ return 9001; }
	@property float HeavyAttackBackStrength()	{ return 9001; }
	@property float HeavyAttackHitTime()		{ return 0.01; }
	@property float HeavyAttackCooldown()		{ return 0.01; }

	@property float SpecialAttackStrength()		{ return 9001; }
	@property float SpecialAttackBackStrength()	{ return 9001; }
	@property float SpecialAttackHitTime()		{ return 0.01; }
	@property float SpecialAttackCooldown()		{ return 0.01; }

	@property bool ShouldRender(bool b)			{ return (bForceRender = b); }
	@property MFMatrix Transform(MFMatrix t)	{ cachedMat = t; return super.Transform = t; }

	void OnRenderWorld()
	{
		super.Transform = cachedMat;
		super.OnRenderWorld();
	}

	private MFMatrix cachedMat;
}
