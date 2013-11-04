module stache.entity.magnumstache;

public import stache.entity.stache;

class MagnumStache : StacheEntity
{
	override @property string CharacterName()			{ return "Magnum P.I."; }
	override @property string PortraitFilename()		{ return "tom"; }
	override @property string ModelFilename()			{ return "magnum_anims.xml"; }
	override @property string SoundsetFilename()		{ return "player2"; }

	/// IStache
	override @property float LightAttackStrength()		{ return 6; }
	override @property float LightAttackBackStrength()	{ return LightAttackStrength * 0.6; }
	override @property float LightAttackHitTime()		{ return 0.14; }
	override @property float LightAttackCooldown()		{ return 0.46; }

	override @property float HeavyAttackStrength()		{ return 9; }
	override @property float HeavyAttackBackStrength()	{ return HeavyAttackStrength * 0.6; }
	override @property float HeavyAttackHitTime()		{ return 0.22; }
	override @property float HeavyAttackCooldown()		{ return 0.55; }

	override @property float SpecialAttackStrength()	{ return 25; }
	override @property float SpecialAttackBackStrength(){ return SpecialAttackStrength * 0.6; }
	override @property float SpecialAttackHitTime()		{ return 0.7; }
	override @property float SpecialAttackCooldown()	{ return 0.8; }
}
