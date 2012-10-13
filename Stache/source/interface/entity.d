module stache.entity.entity;

interface Entity
{
	void OnCreate();
	void OnLoadDone();
	void OnUpdate();
	void OnDraw();
	void OnDeinit();
}