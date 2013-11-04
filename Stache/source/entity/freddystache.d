module stache.entity.freddystache;

public import stache.entity.stache;

class FreddyStache : StacheEntity
{
	override @property string CharacterName()			{ return "Freddie Mercury"; }
	override @property string PortraitFilename()		{ return "freddie"; }
	override @property string ModelFilename()			{ return "freddy_anims.xml"; }
	override @property string SoundsetFilename()		{ return "player1"; }

	/// IStache
	override @property float LightAttackStrength()		{ return 3; }
	override @property float LightAttackBackStrength()	{ return LightAttackStrength * 2; }
	override @property float LightAttackHitTime()		{ return 0.1; }
	override @property float LightAttackCooldown()		{ return 0.2; }

	override @property float HeavyAttackStrength()		{ return 6; }
	override @property float HeavyAttackBackStrength()	{ return HeavyAttackStrength * 2; }
	override @property float HeavyAttackHitTime()		{ return 0.2; }
	override @property float HeavyAttackCooldown()		{ return 0.4; }

	override @property float SpecialAttackStrength()	{ return 11; }
	override @property float SpecialAttackBackStrength(){ return SpecialAttackStrength * 2.3; }
	override @property float SpecialAttackHitTime()		{ return 0.4; }
	override @property float SpecialAttackCooldown()	{ return 0.6; }

}
