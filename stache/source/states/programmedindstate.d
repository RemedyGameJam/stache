module stache.states.programmedindstate;

import stache.i.statemachine;
import stache.i.renderable;

import stache.game;

import fuji.render;
import fuji.material;
import fuji.primitive;
import fuji.view;
import fuji.matrix;
import fuji.system;
import fuji.font;
import fuji.sound;

class ProgrammedInDState : IState, IRenderable
{
	void OnAdd(StateMachine statemachine)
	{
		owner = statemachine;
	}

	void OnEnter()
	{
		chinese = MFFont_Create("ChineseRocks");
		dMan = MFMaterial_Create("D3");

		halfMessageWidth = MFFont_GetStringWidth(chinese, message, messageHeight, 0, -1, null) * 0.5;

		elapsedTime = 0;
	}

	void OnExit()
	{
		MFFont_Destroy(chinese);
		chinese = null;

		MFMaterial_Destroy(dMan);
		dMan = null;
	}

	void OnUpdate()
	{
		elapsedTime += MFSystem_GetTimeDelta();

		if (elapsedTime > 4)
		{
			owner.SwitchState("loading");
		}
	}

	@property StateMachine Owner() { return owner; }

	///IRenderable
	void OnRenderWorld()
	{
		MFRenderer_SetClearColour(0.0, 0.0, 0.0, 1.0);
		MFRenderer_ClearScreen(MFClearScreenFlags.All);

	}

	void OnRenderGUI(MFRect orthoRect)
	{
		MFMaterial_SetMaterial(dMan);

/*		MFPrimitive(PrimType.TriStrip | PrimType.Prelit, 0);
		MFBegin(4);
		{
			MFSetTexCoord1(0, 1);
			MFSetPosition(50, 50, 1);

			MFSetTexCoord1(0, 0);
			MFSetPosition(50, 100, 1);

			MFSetTexCoord1(1, 1);
			MFSetPosition(100, 50, 1);

			MFSetTexCoord1(1, 0);
			MFSetPosition(100, 100, 1);
		}
		MFEnd();*/

		MFPrimitive_DrawQuad(50, 50, 50, 50, MFVector.one, 0, 0, 1, 1, MFMatrix.identity);

		MFFont_DrawText2f(chinese, orthoRect.width * 0.5 - halfMessageWidth, 360, messageHeight, MFVector(0, 0, 0, 1), message);
		MFFont_DrawText2f(chinese, orthoRect.width * 0.5 - halfMessageWidth - 1, 360, messageHeight, MFVector(1, 1, 1, 1), message);
	}

	@property bool CanRenderWorld() { return true; }
	@property bool CanRenderGUI() { return true; }


	private StateMachine owner;

	private MFMaterial* dMan;
	private float elapsedTime;
	private MFFont* chinese;
	private MFSound* dattMamon;

	private float halfMessageWidth;

	const(char*) message = "This game was programmed in D";
	const(float) messageHeight = 80;
}