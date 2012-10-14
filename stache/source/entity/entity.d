module stache.i.entity;

public import std.xml;
public import fuji.matrix;

interface IEntity
{
	void OnCreate(ElementParser element);
	void OnResolve(IEntity[string] loadedEntities);
	void OnReset();
	void OnDestroy();

	// Do movement and other type logic in this one
	void OnUpdate();

	// Need to resolve post-movement collisions, such as punching someone? Here's the place to do it.
	void OnPostUpdate();

	@property bool CanUpdate();
	@property MFMatrix Transform();
	@property string Name();
}
