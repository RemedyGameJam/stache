module stache.game;

import fuji.fuji;
import fuji.system;
import fuji.filesystem;
import fuji.fs.native;

import fuji.render;
import fuji.material;
import fuji.primitive;
import fuji.view;
import fuji.matrix;

import stache.i.statemachine;
import stache.states.programmedindstate;
import stache.states.loadingscreenstate;
import stache.states.mainmenustate;
import stache.states.ingamestate;
import stache.util.eventtypes;

class Timer
{
	this()
	{
		gameStart = lastFrame = mark = MFSystem_ReadRTC();
		tpb = MFSystem_GetRTCFrequency() / 2;
		freq = tpb*2;
	}

	@property double AbsoluteTime()
	{
		return cast(double)(lastFrame - gameStart) / cast(double)freq;
	}

	@property double SinceMark()
	{
		return cast(double)(lastFrame - mark) / cast(double)freq;
	}

	@property double Delta()
	{
		return delta;
	}

	@property double Measure()
	{
		return cast(double)(lastFrame - mark) / tpb * 0.25;
	}

	@property float Beat()
	{
		return cast(double)(lastFrame - mark) / tpb;
	}

	void Mark()
	{
		mark = lastFrame - (lastFrame % tpb);
	}

	void MarkIn(int beats, void delegate() callback)
	{
		markIn = beats;

		if(callback)
			markInEvent += callback;
	}

	void MarkHack()
	{
		markIn = 1;
	}

	void MarkAtNextBeat(void delegate() callback)
	{
		markAtNextBeat = true;

		if(callback)
			markBeatEvent += callback;
	}

	void MarkAtNextMeasure(void delegate() callback)
	{
		markAtNextMeasure = true;

		if(callback)
			markMeasureEvent += callback;
	}

	void AddBeatEvent(void delegate() callback)
	{
		if(callback)
			beatEvent += callback;
	}

	void AddMeasureEvent(void delegate() callback)
	{
		if(callback)
			measureEvent += callback;
	}

	void Update()
	{
		ulong thisFrame = MFSystem_ReadRTC();

		delta = cast(double)(thisFrame - lastFrame) / cast(double)freq;

		ulong lastBeat = (lastFrame - mark) / tpb;
		ulong nextBeat = (thisFrame - mark) / tpb;

		if(lastBeat != nextBeat)
		{
			VoidEvent beat = markBeatEvent;
			VoidEvent measure = markMeasureEvent;
			VoidEvent inBeats = markInEvent;
			bool doBeat, doMeasure, doInBeats;

			// beat frame
			beatEvent();

			if(markAtNextBeat)
			{
				markAtNextBeat = false;
				mark = thisFrame - (thisFrame%tpb);

				markBeatEvent.clear();
				doBeat = true;
			}

			if(nextBeat % 4 == 0)
			{
				// measure frame
				measureEvent();

				if(markAtNextMeasure)
				{
					markAtNextMeasure = false;
					mark = thisFrame - (thisFrame%tpb);

					markMeasureEvent.clear();
					doMeasure = true;
				}
			}

			if(markIn > 0)
			{
				if(nextBeat >= markIn)
				{
					markIn = 0;
					mark = thisFrame - (thisFrame%tpb);

					markInEvent.clear();
					doInBeats = true;
				}
			}

			// defer the calling of the events until after we've processed all the events we need to fire
			if(doBeat)
				beat();
			if(doMeasure)
				measure();
			if(doInBeats)
				inBeats();
		}

		lastFrame = thisFrame;
	}

	ulong gameStart;
	ulong lastFrame;
	ulong freq;
	ulong tpb;

	ulong mark;

	double delta;

	VoidEvent beatEvent;
	VoidEvent measureEvent;

	bool markAtNextBeat;
	bool markAtNextMeasure;
	int markIn;
	VoidEvent markBeatEvent;
	VoidEvent markMeasureEvent;
	VoidEvent markInEvent;
}

class Game
{
	this()
	{
		instance = this;
		state = new StateMachine;
	}

	void InitFileSystem()
	{
		MFFileSystemHandle hNative = MFFileSystem_GetInternalFileSystemHandle(MFFileSystemHandles.NativeFileSystem);
		MFMountDataNative mountData;
		mountData.cbSize = MFMountDataNative.sizeof;
		mountData.priority = MFMountPriority.Normal;
		mountData.flags = MFMountFlags.FlattenDirectoryStructure | MFMountFlags.Recursive;
		mountData.pMountpoint = "data";
		mountData.pPath = MFFile_SystemPath("../Data/");
		MFFileSystem_Mount(hNative, mountData);

		mountData.flags = MFMountFlags.DontCacheTOC;
		mountData.pMountpoint = "cache";
		mountData.pPath = MFFile_SystemPath("../Data/Cache");
		MFFileSystem_Mount(hNative, mountData);
	}

	void Init()
	{

		timer = new Timer();

		state.AddState("programmedind", new ProgrammedInDState);
		state.AddState("loading", new LoadingScreenState);
		state.AddState("mainmenu", new MainMenuState);
		state.AddState("ingame", new InGameState);

		state.SwitchState("programmedind");
	}

	void Deinit()
	{
		state = null;
	}

	void Update()
	{
		timer.Update();

		state.Update();
	}

	void Draw()
	{
		state.Draw();
	}

	MFInitParams mfInitParams;

	Timer timer;

	private StateMachine state;

	///
	private static Game instance;

	@property static Game Instance() { if (instance is null) instance = new Game; return instance; }

	@property static Timer TimeKeeper() { if (instance is null) return null; return instance.timer; }

	static void Static_InitFileSystem()
	{
		Instance.InitFileSystem();
	}

	static void Static_Init()
	{
		Instance.Init();
	}

	static void Static_Deinit()
	{
		Instance.Deinit();
		instance = null;
	}

	static void Static_Update()
	{
		Instance.Update();
	}

	static void Static_Draw()
	{
		Instance.Draw();
	}
}
