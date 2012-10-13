module stache.i.entity;

public import std.xml;
public import fuji.matrix;

interface IEntity
{
	void OnCreate(ElementParser element);
	void OnReset();
	void OnDestroy();
	void OnUpdate();

	@property bool CanUpdate();
	@property MFMatrix Transform();
	@property string Name();
}
