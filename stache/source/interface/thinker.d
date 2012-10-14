module stache.i.thinker;

import fuji.vector;

interface ISheeple
{
	enum Moves
	{
		None = 0,
		LightAttack = 1 << 0,
		HeavyAttack = 1 << 1,
		SpecialAttack = 1 << 2,
		Block = 1 << 3,

		AllAttacks = LightAttack | HeavyAttack | SpecialAttack,
	}

	void OnLightAttack();
	void OnHeavyAttack();
	void OnSpecialAttack();
	void OnBlock();
	void OnUnblock();
	void OnMove(MFVector direction);

	void OnReceiveAttack(Moves type, float strength);

	@property bool CanMove();
	@property bool CanAttack();
	@property bool CanBlock();

	@property float Health();

	@property bool IsAttacking();
	@property bool IsBlocking();
	@property bool IsRunning();
}

interface IThinker
{
	bool OnAssign(ISheeple sheeple);
	void OnThink();

	@property bool Valid();
}
