module stache.thinkers.localplayer;

import stache.i.thinker;

import fuji.vector;
import fuji.input;

class LocalPlayer : IThinker
{
	this(int index)
	{
		playerIndex = index;
		sheeple = null;
		inputDeviceID = -1;
	}

	bool OnAssign(ISheeple sheepWantsToFollow)
	{
		if (devicesClaimed[playerIndex] is null)
		{
			devicesClaimed[playerIndex] = this;
			inputDeviceID = playerIndex;
		}
		else
		{
			foreach (devID; 0 .. devicesClaimed.length)
			{
				if (devicesClaimed[devID] is null)
				{
					devicesClaimed[devID] = this;
					inputDeviceID = devID;
					break;
				}
			}
		}

		if (Valid)
		{
			sheeple = sheepWantsToFollow;
		}

		return Valid;
	}

	void OnThink()
	{
		if (!Ready)
			return;

		if (sheeple.CanMove)
		{
			MFVector direction;
			direction.x = MFInput_Read(MFGamepadButton.Axis_LX, MFInputDevice.Gamepad, inputDeviceID, null);
			direction.z = MFInput_Read(MFGamepadButton.Axis_LY, MFInputDevice.Gamepad, inputDeviceID, null);

			sheeple.OnMove(direction);
		}

		if (sheeple.CanAttack)
		{
			if (MFInput_WasPressed(MFGamepadButton.X3_A, MFInputDevice.Gamepad, inputDeviceID))
				sheeple.OnLightAttack();
			else if (MFInput_WasPressed(MFGamepadButton.X3_B, MFInputDevice.Gamepad, inputDeviceID))
				sheeple.OnHeavyAttack();
			else if (MFInput_WasPressed(MFGamepadButton.X3_Y, MFInputDevice.Gamepad, inputDeviceID))
				sheeple.OnSpecialAttack();
		}

		if (sheeple.CanBlock)
		{
			if (MFInput_WasPressed(MFGamepadButton.X3_X, MFInputDevice.Gamepad, inputDeviceID))
			{
				sheeple.OnBlock();
			}
			else if (MFInput_WasReleased(MFGamepadButton.X3_X, MFInputDevice.Gamepad, inputDeviceID)
				|| sheeple.IsBlocking && MFInput_Read(MFGamepadButton.X3_X, MFInputDevice.Gamepad, inputDeviceID, null) <= 0.0)
			{
				sheeple.OnUnblock();
			}
		}
	}

	@property bool Valid() { return inputDeviceID != -1; }

	@property bool Ready() { return Valid && MFInput_IsReady(MFInputDevice.Gamepad, inputDeviceID); }

	private ISheeple sheeple;
	private int inputDeviceID;
	private int playerIndex;

	private static IThinker[] devicesClaimed = [ null, null, null, null ];
}
