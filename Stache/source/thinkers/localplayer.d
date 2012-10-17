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
		joypadDeviceID = -1;
		keyboardDeviceID = -1;
	}

	enum KeyMoves
	{
		Up,
		Down,
		Left,
		Right,

		Light,
		Heavy,
		Special,
		Block,
	}

	immutable MFKey[KeyMoves.max + 1][4] playerKeyboardMappings =
	[
		[ MFKey.W, MFKey.S, MFKey.A, MFKey.D, MFKey.G, MFKey.H, MFKey.J, MFKey.Y ],
		[ MFKey.Up, MFKey.Down, MFKey.Left, MFKey.Right, MFKey.NumPad4, MFKey.NumPad5, MFKey.NumPad6, MFKey.NumPad8 ],
		[ MFKey.None, MFKey.None, MFKey.None, MFKey.None, MFKey.None, MFKey.None, MFKey.None, MFKey.None ],
		[ MFKey.None, MFKey.None, MFKey.None, MFKey.None, MFKey.None, MFKey.None, MFKey.None, MFKey.None ]
	];

	bool OnAssign(ISheeple sheepWantsToFollow)
	{
		if (padsClaimed[playerIndex] is null && MFInput_IsReady(MFInputDevice.Gamepad, playerIndex))
		{
			padsClaimed[playerIndex] = this;
			joypadDeviceID = playerIndex;
		}
		else
		{
			foreach (devID; 0 .. padsClaimed.length)
			{
				if (padsClaimed[devID] is null && MFInput_IsReady(MFInputDevice.Gamepad, playerIndex))
				{
					padsClaimed[devID] = this;
					joypadDeviceID = cast(int)devID;
					break;
				}
			}
		}

		if (!PadValid)
		{
			foreach(keyID; 0 .. keyboardsClaimed.length)
			{
				if (keyboardsClaimed[keyID] is null)
				{
					keyboardsClaimed[keyID] = this;
					keyboardDeviceID = cast(int)keyID;
					break;
				}
			}
		}

		if (PadValid || KeyboardValid)
		{
			sheeple = sheepWantsToFollow;
		}

		return Valid;
	}

	void OnThink()
	{
		bool	moving = false,
				lightAttacking = false,
				heavyAttacking = false,
				specialAttacking = false,
				blocking = false,
				unblocking = false;

		MFVector direction;

		if (PadReady)
		{
			if (sheeple.CanMove)
			{
				direction.x = MFInput_Read(MFGamepadButton.Axis_LX, MFInputDevice.Gamepad, joypadDeviceID, null);
				direction.z = MFInput_Read(MFGamepadButton.Axis_LY, MFInputDevice.Gamepad, joypadDeviceID, null);

				moving = true;
			}

			if (sheeple.CanAttack)
			{
				if (MFInput_WasPressed(MFGamepadButton.X3_A, MFInputDevice.Gamepad, joypadDeviceID))
					lightAttacking = true;
				else if (MFInput_WasPressed(MFGamepadButton.X3_B, MFInputDevice.Gamepad, joypadDeviceID))
					heavyAttacking = true;
				else if (MFInput_WasPressed(MFGamepadButton.X3_Y, MFInputDevice.Gamepad, joypadDeviceID))
					specialAttacking = true;
			}

			if (sheeple.CanBlock)
			{
				if (MFInput_WasPressed(MFGamepadButton.X3_X, MFInputDevice.Gamepad, joypadDeviceID))
				{
					blocking = true;
				}
				else if (MFInput_WasReleased(MFGamepadButton.X3_X, MFInputDevice.Gamepad, joypadDeviceID)
					|| sheeple.IsBlocking && MFInput_Read(MFGamepadButton.X3_X, MFInputDevice.Gamepad, joypadDeviceID, null) <= 0.0)
				{
					unblocking = true;
				}
			}
		}

		// Keyboard input
		if(KeyboardReady)
		{
			if (sheeple.CanMove)
			{
				float positiveX = MFInput_Read(playerKeyboardMappings[keyboardDeviceID][KeyMoves.Right], MFInputDevice.Keyboard, 0, null);
				float negativeX = MFInput_Read(playerKeyboardMappings[keyboardDeviceID][KeyMoves.Left], MFInputDevice.Keyboard, 0, null);

				float positiveZ = MFInput_Read(playerKeyboardMappings[keyboardDeviceID][KeyMoves.Up], MFInputDevice.Keyboard, 0, null);
				float negativeZ = MFInput_Read(playerKeyboardMappings[keyboardDeviceID][KeyMoves.Down], MFInputDevice.Keyboard, 0, null);

				direction.x = positiveX - negativeX;
				direction.z = positiveZ - negativeZ;

				direction.normalise();

				moving = true;
			}

			if (sheeple.CanAttack)
			{
				if (MFInput_WasPressed(playerKeyboardMappings[keyboardDeviceID][KeyMoves.Light], MFInputDevice.Keyboard, 0))
					lightAttacking = true;
				else if (MFInput_WasPressed(playerKeyboardMappings[keyboardDeviceID][KeyMoves.Heavy], MFInputDevice.Keyboard, 0))
					heavyAttacking = true;
				else if (MFInput_WasPressed(playerKeyboardMappings[keyboardDeviceID][KeyMoves.Special], MFInputDevice.Keyboard, 0))
					specialAttacking = true;
			}

			if (sheeple.CanBlock)
			{
				if (!sheeple.IsBlocking && MFInput_Read(playerKeyboardMappings[keyboardDeviceID][KeyMoves.Block], MFInputDevice.Keyboard, 0, null) > 0)
				{
					blocking = true;
				}
				else if (sheeple.IsBlocking && MFInput_Read(playerKeyboardMappings[keyboardDeviceID][KeyMoves.Block], MFInputDevice.Keyboard, 0, null) <= 0)
				{
					unblocking = true;
				}
			}
		}

		if (moving)
			sheeple.OnMove(direction);

		if (lightAttacking)
			sheeple.OnLightAttack();
		if (heavyAttacking)
			sheeple.OnHeavyAttack();
		if (specialAttacking)
			sheeple.OnSpecialAttack();

		if (blocking)
			sheeple.OnBlock();
		else if (unblocking)
			sheeple.OnUnblock();
	}

	@property bool Valid() { return PadValid || KeyboardValid; }

	@property bool PadValid() { return joypadDeviceID != -1; }
	@property bool KeyboardValid() { return keyboardDeviceID != -1; }

	@property bool PadReady() { return PadValid && MFInput_IsReady(MFInputDevice.Gamepad, joypadDeviceID); }
	@property bool KeyboardReady() { return KeyboardValid; }

	private ISheeple sheeple;
	private int joypadDeviceID;
	private int keyboardDeviceID;
	private int playerIndex;

	private static IThinker[] padsClaimed = [ null, null, null, null ];
	private static IThinker[] keyboardsClaimed = [ null, null, null, null ];
}
