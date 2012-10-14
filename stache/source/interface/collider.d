module stache.i.collider;

public import fuji.vector;
import fuji.collision;

import std.algorithm;

enum CollisionType
{
	Sphere,
	Box,
}

enum CollisionClass // Hack-ish
{
	None = 0,
	Combatant = 1 << 0,
	Stache = 1 << 1,
}

interface ICollider
{
	void OnAddCollision(CollisionManager owner);

	@property MFVector CollisionPosition();
	@property MFVector CollisionPosition(MFVector pos);

	@property MFVector CollisionPrevPosition();

	@property CollisionType CollisionTypeEnum();
	@property CollisionClass CollisionClassEnum();
	@property MFVector CollisionParameters();
}

class CollisionManager
{
	@property MFVector PlaneDimensions(MFVector dim)
	{
		planeDimensions = dim;

		boundingPlanes.clear();

		MFVector rightPoint = MFVector(dim.x, 0, 0, 0);
		MFVector forwardPoint = MFVector(0, 0, dim.z, 0);

		MFVector left = -MFVector.right;
		MFVector back = -MFVector.forward;

		boundingPlanes ~= MFCollision_MakePlaneFromPointAndNormal(MFVector.zero, MFVector.right);
		boundingPlanes ~= MFCollision_MakePlaneFromPointAndNormal(rightPoint, left);

		boundingPlanes ~= MFCollision_MakePlaneFromPointAndNormal(MFVector.zero, MFVector.forward);
		boundingPlanes ~= MFCollision_MakePlaneFromPointAndNormal(forwardPoint, back);

		return planeDimensions;
	}

	void OnUpdate()
	{
		// Resolve against each other first
		foreach(index, sourceCollider; colliders)
		{
			foreach(targetCollider; colliders[index + 1 .. $])
			{
				MFCollisionResult result;

				MFVector sourcePos = sourceCollider.CollisionPosition;
				MFVector targetPos = targetCollider.CollisionPosition;

				if (sourceCollider.CollisionTypeEnum == CollisionType.Sphere && targetCollider.CollisionTypeEnum == CollisionType.Sphere)
				{
					if (MFCollision_SphereSphereTest(sourcePos, sourceCollider.CollisionParameters.x, targetPos, targetCollider.CollisionParameters.x, &result))
					{
						sourceCollider.CollisionPosition = sourcePos + result.normal * (result.depth * 0.5);

						targetCollider.CollisionPosition = targetPos + result.normal * (result.depth * -0.5);
					}
				}
			}
		}

		// Then resolve with edge of world
		foreach(index, collider; colliders)
		{
			MFVector pos = collider.CollisionPosition;
			pos.x = min(max(pos.x, 0), planeDimensions.x);
			pos.z = min(max(pos.z, 0), planeDimensions.z);
			collider.CollisionPosition = pos;
		}

	}

	void AddCollider(ICollider collider)
	{
		colliders ~= collider;
		collider.OnAddCollision(this);
	}

	void RemoveCollider(ICollider collider)
	{
		int index = countUntil(colliders, collider);
		if (index != -1)
			remove(colliders, index);
	}

	ICollider[] FindCollisionSphere(MFVector pos, float radius, CollisionClass validTypes, ICollider ignore = null)
	{
		ICollider[] found;

		foreach(collider; colliders)
		{
			if (collider == ignore)
				continue;

			if ((collider.CollisionClassEnum & validTypes) == CollisionClass.None)
				continue;

			MFVector colliderPos = collider.CollisionPosition;

			if (collider.CollisionTypeEnum == CollisionType.Sphere
				&& MFCollision_SphereSphereTest(pos, radius, colliderPos, collider.CollisionParameters.x, null))
			{
				found ~= collider;
			}
		}

		return found;
	}

	private ICollider[] colliders;
	private MFVector planeDimensions;

	private MFVector[] boundingPlanes;
}