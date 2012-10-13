module stache.i.renderable;

public import fuji.types;

interface IRenderable
{
	void OnRenderWorld();
	void OnRenderGUI(MFRect orthoRect);

	@property bool CanRenderWorld();
	@property bool CanRenderGUI();
}