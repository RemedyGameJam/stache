module stache.sound.soundset;

import fuji.filesystem;
import fuji.sound;

import std.xml;
import std.string;
import std.random;

class SoundSet
{
	this(string xml)
	{
		size_t length;
		const(char*) rawData = MFFileSystem_Load((xml ~ ".xml").toStringz, &length, false);

		string data = rawData[0 .. length].idup;

		DocumentParser doc = new DocumentParser(data);

		doc.onStartTag["soundset"] = (ElementParser setTag)
		{
			setTag.onStartTag["group"] = (ElementParser groupTag)
			{
				string group = groupTag.tag.attr["name"];

				groupTag.onStartTag["sound"] = (ElementParser soundTag)
				{
					string sound = soundTag.tag.attr["file"];

					MFSound* s = MFSound_Create(sound.toStringz);
					if(s)
						groups[group] ~= Sound(s);
				};

				groupTag.parse();
			};

			setTag.parse();
		};

		doc.parse();
	}

	void Destroy()
	{
		foreach(group; groups)
		{
			foreach(s; group)
				MFSound_Destroy(s.sound);
		}

//		groups.
	}

	float Play(const(char[]) group)
	{
		if(group !in groups)
			return 0;
		if(groups[group].length == 0)
			return 0;

		int i = cast(int)uniform(0, groups[group].length);

		MFSoundInfo info;
		MFSound_GetSoundInfo(groups[group][i].sound, &info);

		MFSound_Play(groups[group][i].sound, 0);

		return cast(float)info.numSamples / cast(float)info.sampleRate;
	}

	struct Sound
	{
		MFSound* sound;
	}

	Sound[][string] groups;
}
