module stache.entity.dictatorstache;

public import stache.entity.stache;

class DictatorStache : StacheEntity
{
	override @property string CharacterName()			{ return "Great Dictator"; }
	override @property string PortraitFilename()		{ return "dictator2"; }
	override @property string ModelFilename()			{ return "dictator_anims.xml"; }
	override @property string SoundsetFilename()		{ return "player2"; }

	/// IStache
	override @property float LightAttackStrength()		{ return 7; }
	override @property float LightAttackBackStrength()	{ return 2; }
	override @property float LightAttackHitTime()		{ return 0.06; }
	override @property float LightAttackCooldown()		{ return 0.3; }

	override @property float HeavyAttackStrength()		{ return 10; }
	override @property float HeavyAttackBackStrength()	{ return 4; }
	override @property float HeavyAttackHitTime()		{ return 0.1; }
	override @property float HeavyAttackCooldown()		{ return 0.4; }

	override @property float SpecialAttackStrength()	{ return 30; }
	override @property float SpecialAttackBackStrength(){ return 10; }
	override @property float SpecialAttackHitTime()		{ return 0.1; }
	override @property float SpecialAttackCooldown()	{ return 1.3; }

}
