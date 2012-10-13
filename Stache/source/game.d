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
import stache.states.loadingscreenstate;
import stache.states.mainmenustate;

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
	}

	void Init()
	{
		state.AddState("loading", new LoadingScreenState);
		state.AddState("mainmenu", new MainMenuState);

		state.SwitchState("loading");
	}

	void Deinit()
	{
	}

	void Update()
	{
		state.Update();
	}

	void Draw()
	{
		state.Draw();
	}

	MFInitParams mfInitParams;

	private StateMachine state;

	///
	private static Game instance;

	@property static Game Instance() { if (instance is null) instance = new Game; return instance; }

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
