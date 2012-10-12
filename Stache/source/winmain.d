module stache.winmain;

import core.runtime;
import core.sys.windows.windows;

import fuji.system;

import stache.game;

extern (Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
    int result;

    void exceptionHandler(Throwable e)
    {
        throw e;
    }

    try
    {
        Runtime.initialize(&exceptionHandler);

        result = myWinMain(hInstance, hPrevInstance, lpCmdLine, nCmdShow);

        Runtime.terminate(&exceptionHandler);
    }
    catch (Throwable o)		// catch any uncaught exceptions
    {
        MessageBoxA(null, cast(char *)o.toString(), "Error", MB_OK | MB_ICONEXCLAMATION);
        result = 0;		// failed
    }

    return result;
}

int myWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
    /* ... insert user code here ... */
//    throw new Exception("not implemented");

	Game game = Game.Instance;

	game.mfInitParams.hInstance = hInstance;
	game.mfInitParams.pCommandLine = lpCmdLine;

	MFSystem_RegisterSystemCallback(MFCallback.FileSystemInit, &Game.Static_InitFileSystem);
	MFSystem_RegisterSystemCallback(MFCallback.InitDone, &Game.Static_Init);
	MFSystem_RegisterSystemCallback(MFCallback.Deinit, &Game.Static_Deinit);
	MFSystem_RegisterSystemCallback(MFCallback.Update, &Game.Static_Update);
	MFSystem_RegisterSystemCallback(MFCallback.Draw, &Game.Static_Draw);

	return MFMain(game.mfInitParams);
}
