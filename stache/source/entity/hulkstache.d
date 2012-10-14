module stache.entity.hulkstache;

public import stache.entity.stache;

class HulkStache : StacheEntity
{
	@property string ModelFilename()		{ return "hogan_anims.xml"; }
	@property string SoundsetFilename()		{ return "player1"; }

	/// IStache
	@property float LightAttackStrength()	{ return 5; }
	@property float LightAttackHitTime()	{ return 0.1; }
	@property float LightAttackCooldown()	{ return 0.445; }

	@property float HeavyAttackStrength()	{ return 10; }
	@property float HeavyAttackHitTime()	{ return 0.3; }
	@property float HeavyAttackCooldown()	{ return 0.6; }

	@property float SpecialAttackStrength()	{ return 16; }
	@property float SpecialAttackBackStrength()	{ return SpecialAttackStrength * 1.3; }
	@property float SpecialAttackHitTime()	{ return 0.5; }
	@property float SpecialAttackCooldown()	{ return 1.0; }

}
