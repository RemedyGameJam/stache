module stache.i.statemachine;

public import stache.i.renderable;
public import fuji.display;
public import fuji.view;

interface IState : IRenderable
{
	void OnAdd(StateMachine statemachine);
	void OnEnter();
	void OnExit();
	void OnUpdate();

	@property StateMachine Owner();
}

class StateMachine
{
	this()
	{
		currState = null;
		nextState = null;
		states.clear();
	}

	~this()
	{
		if (currState !is null)
			currState.OnExit();
	}

	void AddState(string name, IState state)
	{
		foreach(stateName, state; states)
		{
			assert(stateName != name, "State " ~ name ~ " already exists!");
		}

		states[name] = state;
		state.OnAdd(this);
	}

	void SwitchState(string requestedState)
	{
		foreach(stateName, state; states)
		{
			if (stateName == requestedState && state != currState)
			{
				nextState = state;
				break;
			}
		}
	}

	void Update()
	{
		if (nextState !is null)
		{
			if (currState !is null)
				currState.OnExit();

			currState = nextState;
			currState.OnEnter();
			nextState = null;
		}

		if (currState !is null)
			currState.OnUpdate();
	}

	void Draw()
	{
		if (currState !is null)
		{
			currState.OnRenderWorld();

			MFView_Push();
			{
				MFView_SetDefault();

				MFRect rect;
				MFRect display;

				MFDisplay_GetDisplayRect(&display);

				rect.x = 0.0f;
				rect.y = 0.0f;
				rect.width = 1280; //display.height * MFDisplay_GetNativeAspectRatio();
				rect.height = 720; //display.height;

				MFView_SetOrtho(&rect);

				currState.OnRenderGUI(rect);
			}
			MFView_Pop();
		}
	}

	private IState[string] states;
	private IState currState;
	private IState nextState;
}
