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

class Game
{
	this()
	{
		instance = this;
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
		mattDamon = MFMaterial_Create("MattDamon");
	}

	void Deinit()
	{
		int foo = 0;
	}

	void Update()
	{
		int foo = 0;
	}

	void Draw()
	{
		MFRenderer_SetClearColour(0.1, 0.0, 0.1, 1.0);
		MFRenderer_ClearScreen(MFClearScreenFlags.All);

		MFView_Push();
		{
			float x = MFDeg2Rad!60;
			MFView_ConfigureProjection(x, 0.01, 100000);
			MFView_SetAspectRatio(mfInitParams.display.displayRect.width / mfInitParams.display.displayRect.height);
			MFView_SetProjection();

			MFView_SetCameraMatrix(MFMatrix.identity);

			MFMaterial_SetMaterial(mattDamon);

			MFPrimitive(PrimType.TriStrip | PrimType.Prelit, 0);
			MFBegin(4);
			{
				MFSetTexCoord1(0, 1);
				MFSetPosition(-1, -1, 2);

				MFSetTexCoord1(0, 0);
				MFSetPosition(-1, 1, 2);

				MFSetTexCoord1(1, 1);
				MFSetPosition(1, -1, 2);

				MFSetTexCoord1(1, 0);
				MFSetPosition(1, 1, 2);
			}
			MFEnd();

		}
		MFView_Pop();
	}

	MFInitParams mfInitParams;

	MFMaterial* mattDamon;

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
