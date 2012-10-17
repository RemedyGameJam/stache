module stache.sound.music;

import fuji.filesystem;
import fuji.sound;

import std.xml;
import std.string;
import std.conv;

class Music
{
	this(string xml)
	{
		size_t length;
		const(char*) rawData = MFFileSystem_Load((xml ~ ".xml").toStringz, &length, false);

		string data = rawData[0 .. length].idup;

		DocumentParser doc = new DocumentParser(data);

		doc.onStartTag["music"] = (ElementParser xml)
		{
			xml.onStartTag["stream"] = (ElementParser xml)
			{
				string music = xml.tag.attr["track"];

				MFAudioStream* stream = MFSound_CreateStream(music.toStringz, MFAudioStreamFlags.AllowSeeking);
				if(stream)
				{
					string vol = xml.tag.attr["vol"];
					streams ~= Stream(stream, vol ? to!float(vol) : 1);
					MFSound_PlayStream(stream, MFPlayFlags.Looping | MFPlayFlags.BeginPaused);
				}
			};

			xml.parse();
		};

		doc.parse();
	}

	void Destroy()
	{
		foreach(s; streams)
			MFSound_DestroyStream(s.stream);
		streams = null;
	}

	void SetMasterVolume(float vol)
	{
		masterVol = vol;
		ResetVolumes();
	}

	void SetTrackVolume(int track, float vol)
	{
		if(track >= streams.length)
			return;

		streams[track].vol = vol;

		MFVoice* voice = MFSound_GetStreamVoice(streams[track].stream);
		MFSound_SetVolume(voice, vol * masterVol);
	}

	@property bool Playing(bool playing)
	{
		if(bPlaying != playing)
		{
			bPlaying = playing;

			foreach(s; streams)
				MFSound_PauseStream(s.stream, !playing);

			if(playing)
				ResetVolumes();
		}
		return playing;
	}

	@property bool Playing() { return bPlaying; }


	private void ResetVolumes()
	{
		foreach(i, s; streams)
			SetTrackVolume(cast(int)i, s.vol);
	}

	bool bPlaying;

	float masterVol = 1;

	struct Stream
	{
		MFAudioStream* stream;
		float vol = 1;
	}

	Stream[] streams;
}
