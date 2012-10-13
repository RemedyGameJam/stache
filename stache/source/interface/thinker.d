module stache.i.thinker;

import fuji.vector;

interface ISheeple
{
	void OnLightAttack();
	void OnHeavyAttach();
	void OnSpecialAttack();
	void OnMove(MFVector direction);
}

interface IThinker
{
	void OnAssign(ISheeple sheeple);
	void OnThink();
	void OnIssueCommand();
}
