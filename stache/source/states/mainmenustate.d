module stache.states.mainmenustate;

import stache.game;
import stache.i.statemachine;

import fuji.render;
import fuji.matrix;

class MainMenuState : IState
{
	void OnAdd(StateMachine statemachine)
	{
		owner = statemachine;
	}

	void OnEnter()
	{
	}

	void OnExit()
	{
	}

	void OnUpdate()
	{
	}

	@property StateMachine Owner() { return owner; }
	private StateMachine owner;

	///IRenderable
	void OnRenderWorld()
	{
		MFRenderer_SetClearColour(0.1, 0.0, 0.1, 1.0);
		MFRenderer_ClearScreen(MFClearScreenFlags.All);

		MFView_Push();
		{
			float x = MFDeg2Rad!60;
			MFView_ConfigureProjection(x, 0.01, 100000);
			// TODO: Nasty singletonses
			float ratio = Game.Instance.mfInitParams.display.displayRect.width / Game.Instance.mfInitParams.display.displayRect.height;
			MFView_SetAspectRatio(ratio);
			MFView_SetProjection();

			MFView_SetCameraMatrix(MFMatrix.identity);

		}
		MFView_Pop();

	}

	void OnRenderGUI(MFRect orthoRect)
	{
	}

	@property bool CanRenderWorld() { return true; }
	@property bool CanRenderGUI() { return true; }
}