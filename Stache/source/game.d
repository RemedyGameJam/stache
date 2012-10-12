module stache.game;

import fuji.system;
import fuji.filesystem;
import fuji.fs.native;

import fuji.render;

class Game
{
	this()
	{
		instance = this;
	}

	static void InitFileSystem()
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

	static void Init()
	{
		int foo = 0;
	}

	static void Deinit()
	{
		int foo = 0;
	}

	static void Update()
	{
		int foo = 0;
	}

	static void Draw()
	{
		MFRenderer_SetClearColour(1.0, 0.0, 1.0, 1.0);
		MFRenderer_ClearScreen(MFClearScreenFlags.All);

	}

	MFInitParams mfInitParams;


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
