module stache.util.meshanimator;

import fuji.model;
import fuji.filesystem;
import fuji.system;

import std.conv;
import std.xml;
import std.string;
import std.stdio;

class MeshAnimator
{
	class Frame
	{
		MFModel* model =  null;
		float percent = 0;
	}

	class Anim
	{
		Frame[] frames = null;
		float totalTime = 0;
		bool loops = false;
		bool isDefault = true;

		float timeToNextFrame = 0;
		int frameIndex = 0;

		@property MFModel* Mesh() { int lookup = frameIndex; if (lookup >= frames.length) lookup = frames.length - 1; return frames[lookup].model; }
	}

	class Mesh
	{
		MFModel* model = null;
	}

	this(string filename)
	{
		OnCreate(filename);
	}

	void OnCreate(string filename)
	{
		size_t length;
		const(char*) rawData = MFFileSystem_Load(filename.toStringz, &length, false);

		string data = rawData[0 .. length].idup;

		DocumentParser doc = new DocumentParser(data);

		doc.onStartTag["meshes"] = (ElementParser meshesTag)
		{
			meshesTag.onStartTag["mesh"] = (ElementParser meshTag)
			{
				string meshName = meshTag.tag.attr["name"];
				Mesh newMesh = new Mesh;
				newMesh.model = MFModel_Create(meshTag.tag.attr["filename"].toStringz);

				meshes[meshName] = newMesh;

				meshTag.parse();
			};

			meshesTag.parse();
		};

		doc.onStartTag["anims"] = (ElementParser animsTag)
		{
			animsTag.onStartTag["anim"] = (ElementParser animTag)
			{
				string animName = animTag.tag.attr["name"];
				Anim newAnim = new Anim;
				string timeTag = animTag.tag.attr["time"];

				newAnim.totalTime = to!float(timeTag);

				newAnim.loops = to!int(animTag.tag.attr["loop"]) != 0;
				newAnim.isDefault = to!int(animTag.tag.attr["default"]) != 0;
				animTag.onStartTag["frame"] = (ElementParser frameTag)
				{
					Frame newFrame = new Frame;

					newFrame.model = meshes[frameTag.tag.attr["mesh"]].model;
					newFrame.percent = to!float(frameTag.tag.attr["percent"]);

					newAnim.frames ~= newFrame;

					frameTag.parse();
				};

				animTag.parse();

				anims[animName] = newAnim;

				if (newAnim.isDefault)
				{
					currentAnim = defaultAnim = newAnim;
					currentAnim.frameIndex = 0;
					currentAnim.timeToNextFrame = currentAnim.frames[currentAnim.frameIndex].percent * currentAnim.totalTime;
				}
			};

			animsTag.parse();
		};

		doc.parse();
	}

	void OnDestroy()
	{
		foreach(mesh; meshes)
		{
			MFModel_Destroy(mesh.model);
		}
	}

	void OnReset()
	{
		currentAnim = defaultAnim;
		currentAnim.frameIndex = 0;
		currentAnim.timeToNextFrame = currentAnim.frames[currentAnim.frameIndex].percent * currentAnim.totalTime;
	}

	void SetAnimation(string animName)
	{
		currentAnim = anims[animName];
		currentAnim.frameIndex = 0;
		currentAnim.timeToNextFrame = currentAnim.frames[currentAnim.frameIndex].percent * currentAnim.totalTime;
	}

	void OnUpdate()
	{
		if (currentAnim.frameIndex < currentAnim.frames.length)
		{
			currentAnim.timeToNextFrame -= MFSystem_GetTimeDelta();

			while (currentAnim.timeToNextFrame <= 0 && currentAnim.frameIndex < currentAnim.frames.length)
			{
				++currentAnim.frameIndex;
				if (currentAnim.frameIndex >= currentAnim.frames.length && currentAnim.loops)
					currentAnim.frameIndex = 0;

				if (currentAnim.frameIndex < currentAnim.frames.length)
					currentAnim.timeToNextFrame += currentAnim.frames[currentAnim.frameIndex].percent * currentAnim.totalTime;
			}
		}
	}

	@property MFModel* CurrentMesh() { return currentAnim.Mesh; }

	Mesh[string] meshes;
	Anim[string] anims;

	Anim currentAnim;
	Anim defaultAnim;
}
