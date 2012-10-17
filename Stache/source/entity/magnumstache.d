module stache.entity.magnumstache;

public import stache.entity.stache;

class MagnumStache : StacheEntity
{
	@property string CharacterName()			{ return "Magnum P.I."; }
	@property string PortraitFilename()			{ return "tom"; }
	@property string ModelFilename()			{ return "magnum_anims.xml"; }
	@property string SoundsetFilename()			{ return "player2"; }

	/// IStache
	@property float LightAttackStrength()		{ return 6; }
	@property float LightAttackBackStrength()	{ return LightAttackStrength * 0.6; }
	@property float LightAttackHitTime()		{ return 0.14; }
	@property float LightAttackCooldown()		{ return 0.46; }

	@property float HeavyAttackStrength()		{ return 9; }
	@property float HeavyAttackBackStrength()	{ return HeavyAttackStrength * 0.6; }
	@property float HeavyAttackHitTime()		{ return 0.22; }
	@property float HeavyAttackCooldown()		{ return 0.55; }

	@property float SpecialAttackStrength()		{ return 25; }
	@property float SpecialAttackBackStrength()	{ return SpecialAttackStrength * 0.6; }
	@property float SpecialAttackHitTime()		{ return 0.7; }
	@property float SpecialAttackCooldown()		{ return 0.8; }
}
