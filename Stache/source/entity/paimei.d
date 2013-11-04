module stache.entity.paimei;

public import stache.entity.stache;

class PaiMei : StacheEntity
{
	override @property string ModelFilename()			{ return "paimei_anims.xml"; }
	override @property string SoundsetFilename()		{ return "player2"; }

	/// IStache
	override @property float LightAttackStrength()		{ return 9001; }
	override @property float LightAttackBackStrength()	{ return 9001; }
	override @property float LightAttackHitTime()		{ return 0.01; }
	override @property float LightAttackCooldown()		{ return 0.01; }

	override @property float HeavyAttackStrength()		{ return 9001; }
	override @property float HeavyAttackBackStrength()	{ return 9001; }
	override @property float HeavyAttackHitTime()		{ return 0.01; }
	override @property float HeavyAttackCooldown()		{ return 0.01; }

	override @property float SpecialAttackStrength()	{ return 9001; }
	override @property float SpecialAttackBackStrength(){ return 9001; }
	override @property float SpecialAttackHitTime()		{ return 0.01; }
	override @property float SpecialAttackCooldown()	{ return 0.01; }

	@property bool ShouldRender(bool b)					{ return (bForceRender = b); }
	override @property MFMatrix Transform(MFMatrix t)	{ cachedMat = t; return super.Transform = t; }

	override void OnRenderWorld()
	{
		super.Transform = cachedMat;
		super.OnRenderWorld();
	}

	private MFMatrix cachedMat;
}
