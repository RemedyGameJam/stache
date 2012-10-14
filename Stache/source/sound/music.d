module stache.sound.music;

import fuji.filesystem;
import fuji.sound;

import std.xml;
import std.string;

class Music
{
	this(string xml)
	{
		size_t length;
		const(char*) rawData = MFFileSystem_Load((xml ~ ".xml").toStringz, &length, false);

		string data = rawData[0 .. length].idup;
		try
		{
			check(data);
		}
		catch (CheckException e)
		{
			string failure = e.toString();
		}

		DocumentParser doc = new DocumentParser(data);

		doc.onStartTag["music"] = (ElementParser xml)
		{
			xml.onStartTag["stream"] = (ElementParser xml)
			{
				string music = xml.tag.attr["track"];

				stream = MFSound_CreateStream(music.toStringz, MFAudioStreamFlags.AllowSeeking);
				if(stream)
					MFSound_PlayStream(stream, MFPlayFlags.Looping | MFPlayFlags.BeginPaused);
			};

			xml.parse();
		};

		doc.parse();
	}

	@property bool Playing(bool playing) { if(bPlaying != playing) { bPlaying = playing; MFSound_PauseStream(stream, !playing); } return playing; }
	@property bool Playing() { return bPlaying; }

	bool bPlaying;

	MFAudioStream* stream;
}
