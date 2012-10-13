module stache.i.thinker;

import fuji.vector;

interface ISheeple
{
	void OnLightAttack();
	void OnHeavyAttack();
	void OnSpecialAttack();
	void OnBlock();
	void OnUnblock();
	void OnMove(MFVector direction);

	@property bool CanMove();
	@property bool CanAttack();
	@property bool CanBlock();

	@property int Health();

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
