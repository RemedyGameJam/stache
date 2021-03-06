module stache.winmain;

import core.runtime;

import fuji.system;
import fuji.display;

import stache.game;

version(Windows)
{
	import core.sys.windows.windows;
	extern (Windows) int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
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

		MFRect failure;

		MFDisplay_GetNativeRes(&failure);

		game.mfInitParams.hInstance = hInstance;
		game.mfInitParams.pCommandLine = lpCmdLine;
		game.mfInitParams.hideSystemInfo = true;

		game.mfInitParams.display.displayRect.width = failure.width;
		game.mfInitParams.display.displayRect.height = failure.height;
		game.mfInitParams.display.bFullscreen = true;
		game.mfInitParams.pAppTitle = "Matt Damon presents: Stache!".ptr;

		MFSystem_RegisterSystemCallback(MFCallback.FileSystemInit, &Game.Static_InitFileSystem);
		MFSystem_RegisterSystemCallback(MFCallback.InitDone, &Game.Static_Init);
		MFSystem_RegisterSystemCallback(MFCallback.Deinit, &Game.Static_Deinit);
		MFSystem_RegisterSystemCallback(MFCallback.Update, &Game.Static_Update);
		MFSystem_RegisterSystemCallback(MFCallback.Draw, &Game.Static_Draw);

		return MFMain(game.mfInitParams);
	}
}
else
{
	int main(string args[])
	{
	    int result;

	    void exceptionHandler(Throwable e)
	    {
	        throw e;
	    }

	    try
	    {
	        Runtime.initialize(&exceptionHandler);

	        result = myMain(args);

	        Runtime.terminate(&exceptionHandler);
	    }
	    catch (Throwable o)		// catch any uncaught exceptions
	    {
	        result = 0;		// failed
	    }

	    return result;
	}

	int myMain(string args[])
	{
	    /* ... insert user code here ... */
	//    throw new Exception("not implemented");

		Game game = Game.Instance;

		MFRect failure;

		MFDisplay_GetNativeRes(&failure);

//		game.mfInitParams.pCommandLine = lpCmdLine;
		game.mfInitParams.hideSystemInfo = true;

		game.mfInitParams.display.displayRect.width = failure.width;
		game.mfInitParams.display.displayRect.height = failure.height;
		game.mfInitParams.display.bFullscreen = true;
		game.mfInitParams.pAppTitle = "Matt Damon presents: Stache!".ptr;

		MFSystem_RegisterSystemCallback(MFCallback.FileSystemInit, &Game.Static_InitFileSystem);
		MFSystem_RegisterSystemCallback(MFCallback.InitDone, &Game.Static_Init);
		MFSystem_RegisterSystemCallback(MFCallback.Deinit, &Game.Static_Deinit);
		MFSystem_RegisterSystemCallback(MFCallback.Update, &Game.Static_Update);
		MFSystem_RegisterSystemCallback(MFCallback.Draw, &Game.Static_Draw);

		return MFMain(game.mfInitParams);
	}	
}