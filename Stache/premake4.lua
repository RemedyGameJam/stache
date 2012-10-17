solution "Stache"
	if _ACTION == "gmake" then
		configurations { "Release", "Debug" }
	else
		configurations { "Debug", "Release" }
	end

--	platforms { "Native", "x32", "x64" }
	platforms { "Native" }

	project "Stache"
		kind "WindowedApp"
		language "D"

		files { "source/**.d" }
		files { "../../Fuji-D/fuji/**.d" }

		includedirs { "../Fuji-D/" }

		links { "Fuji" }

		flags { "Symbols" }

		targetname "Stache"
		targetdir "bin"
		objdir "build"

