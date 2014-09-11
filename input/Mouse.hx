package input;

import types.MouseEvent;
import types.Vector2;

import msignal.Signal;

class Mouse
{
	public var state (default, null) : Map<MouseButton, MouseButtonState>;
	public var onButtonEvent(default, null) : Signal1<MouseButtonEvent>;
	public var onMovementEvent(default, null) : Signal1<MouseMovementEvent>;
	public var screenPosition : Vector2;
	/// called from within the package, should not be created from the outside
	private function new()
	{
		state = [
			MouseButtonLeft => MouseButtonStateUp,
			MouseButtonRight => MouseButtonStateUp,
			MouseButtonMiddle => MouseButtonStateUp
		];
		onButtonEvent = new Signal1();
		onMovementEvent = new Signal1();
		screenPosition = new Vector2();
	}
}