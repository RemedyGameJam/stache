module stache.entity.stache;

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
