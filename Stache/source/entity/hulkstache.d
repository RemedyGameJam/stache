module stache.entity.hulkstache;

public import stache.entity.stache;

class HulkStache : StacheEntity
{
	override @property string CharacterName()			{ return "The Hulkster"; }
	override @property string PortraitFilename()		{ return "hulk"; }
	override @property string ModelFilename()			{ return "hogan_anims.xml"; }
	override @property string SoundsetFilename()		{ return "player1"; }

	/// IStache
	override @property float LightAttackStrength()		{ return 5; }
	override @property float LightAttackHitTime()		{ return 0.1; }
	override @property float LightAttackCooldown()		{ return 0.445; }

	override @property float HeavyAttackStrength()		{ return 10; }
	override @property float HeavyAttackHitTime()		{ return 0.3; }
	override @property float HeavyAttackCooldown()		{ return 0.6; }

	override @property float SpecialAttackStrength()	{ return 16; }
	override @property float SpecialAttackBackStrength(){ return 16 * 1.3; }
	override @property float SpecialAttackHitTime()		{ return 0.5; }
	override @property float SpecialAttackCooldown()	{ return 0.8; }

}
