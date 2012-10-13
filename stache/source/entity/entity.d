module stache.i.entity;

interface IEntity
{
	void OnCreate();
	void OnDestroy();
	void OnLoadDone();
	void OnUpdate();

	@property bool CanUpdate();
}
