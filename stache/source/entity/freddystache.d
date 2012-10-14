module stache.entity.freddystache;

public import stache.entity.stache;

class FreddyStache : StacheEntity
{
	@property string ModelFilename()			{ return "Hogan_walk_static"; }

	/// IStache
	@property float LightAttackStrength()		{ return 3; }
	@property float LightAttackBackStrength()	{ return LightAttackStrength * 2; }
	@property float LightAttackHitTime()		{ return 0.045; }
	@property float LightAttackCooldown()		{ return 0.3; }

	@property float HeavyAttackStrength()		{ return 6; }
	@property float HeavyAttackBackStrength()	{ return LightAttackStrength * 2; }
	@property float HeavyAttackHitTime()		{ return 0.2; }
	@property float HeavyAttackCooldown()		{ return 0.3; }

	@property float SpecialAttackStrength()		{ return 11; }
	@property float SpecialAttackBackStrength()	{ return SpecialAttackStrength * 2.3; }
	@property float SpecialAttackHitTime()		{ return 0.4; }
	@property float SpecialAttackCooldown()		{ return 0.6; }

}
