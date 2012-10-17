module stache.states.mainmenustate;

import stache.game;
import stache.i.statemachine;

import fuji.render;
import fuji.matrix;
import fuji.font;

class MainMenuState : IState
{
	void OnAdd(StateMachine statemachine)
	{
		owner = statemachine;
	}

	void OnEnter()
	{
		arial = MFFont_Create("Arial");

		halfMessageWidth = MFFont_GetStringWidth(arial, message, messageHeight, 0, -1, null) * 0.5;
	}

	void OnExit()
	{
		MFFont_Destroy(arial);
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
		MFFont_DrawText2f(arial, orthoRect.width * 0.5 - halfMessageWidth, 515, messageHeight, MFVector(0, 0, 0, 1), "Press START to win!");
		MFFont_DrawText2f(arial, orthoRect.width * 0.5 - halfMessageWidth - 1, 514, messageHeight, MFVector(1, 1, 1, 1), "Press START to win!");
	}

	@property bool CanRenderWorld() { return true; }
	@property bool CanRenderGUI() { return true; }

	private MFFont* arial;
	private float halfMessageWidth;

	const(char*) message = "Press START to win!";
	const(float) messageHeight = 45;
}
