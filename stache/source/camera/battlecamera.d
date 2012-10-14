module stache.battlecamera;

public import stache.camera;
public import stache.i.entity;

import std.algorithm;
import std.math;

class BattleCamera : Camera
{
	const float cameraScaleyDistance = 10;
	const float defaultCameraHeight = 2;
	const float defaultStartHeight = 16;

	void AddTrackedEntity(IEntity entity)
	{
		entities ~= entity;
	}

	void OnReset()
	{
		MFVector middlePos;

		foreach(ent; entities)
		{
			middlePos += ent.Transform.t;
		}

		middlePos /= cast(float) entities.length;
		middlePos.y = defaultStartHeight;

		targetMiddlePos = middlePos;
		transform.t = targetMiddlePos;
	}

	void OnPostUpdate()
	{
		MFVector middlePos;

		float minX = float.max;
		float maxX = float.min;

		float minZ = float.max;
		float maxZ = float.min;

		foreach(index, ent; entities)
		{
			middlePos += ent.Transform.t;

			minX = min(minX, ent.Transform.t.x);
			maxX = max(maxX, ent.Transform.t.x);

			minZ = min(minZ, ent.Transform.t.z);
			maxZ = max(maxZ, ent.Transform.t.z);
		}

		middlePos /= cast(float) entities.length;

		targetMiddlePos = lerp!3(targetMiddlePos, middlePos, 0.02);

		float rangeX = maxX - minX;
		float rangeZ = maxZ - minZ;
		float range = sqrt(rangeX * rangeX + rangeZ * rangeZ);

		float result = range * cos(1 - (HorizontalFOV * 0.5));

		transform.t.x = targetMiddlePos.x;
		transform.t.z = targetMiddlePos.z - pow(result, 0.94);

 		transform.t.y = defaultCameraHeight + pow(result * 0.25, 1.2);

		transform.z = normalise(targetMiddlePos - transform.t);
		transform.y = cross3(transform.z, transform.x);
	}

	IEntity[] entities;

	private MFVector targetMiddlePos;
}
