module stache.entity.dictatorstache;

public import stache.entity.stache;

class DictatorStache : StacheEntity
{
	@property string CharacterName()			{ return "Great Dictator"; }
	@property string PortraitFilename()			{ return "dictator2"; }
	@property string ModelFilename()			{ return "dictator_anims.xml"; }
	@property string SoundsetFilename()			{ return "player2"; }

	/// IStache
	@property float LightAttackStrength()		{ return 7; }
	@property float LightAttackBackStrength()	{ return 2; }
	@property float LightAttackHitTime()		{ return 0.06; }
	@property float LightAttackCooldown()		{ return 0.3; }

	@property float HeavyAttackStrength()		{ return 10; }
	@property float HeavyAttackBackStrength()	{ return 4; }
	@property float HeavyAttackHitTime()		{ return 0.1; }
	@property float HeavyAttackCooldown()		{ return 0.4; }

	@property float SpecialAttackStrength()		{ return 30; }
	@property float SpecialAttackBackStrength()	{ return 10; }
	@property float SpecialAttackHitTime()		{ return 0.1; }
	@property float SpecialAttackCooldown()		{ return 1.3; }

}
