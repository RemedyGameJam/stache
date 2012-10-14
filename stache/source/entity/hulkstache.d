module stache.entity.hulkstache;

public import stache.entity.stache;

class HulkStache : IStache
{
	@property float LightAttackStrength()	{ return 5; }
	@property float LightAttackHitTime()	{ return 0.05; }
	@property float LightAttackCooldown()	{ return 0.5; }

	@property float HeavyAttackStrength()	{ return 10; }
	@property float HeavyAttackHitTime()	{ return 0.4; }
	@property float HeavyAttackCooldown()	{ return 0.75; }

	@property float SpecialAttackStrength()	{ return 16; }
	@property float SpecialAttackHitTime()	{ return 0.5; }
	@property float SpecialAttackCooldown()	{ return 1.0; }
}
