package input;

enum MouseButtonState
{
    MouseButtonStateDown;
    MouseButtonStateUp;
    MouseButtonStateMove;
}

enum MouseButton
{
	MouseButtonLeft;
	MouseButtonRight;
	MouseButtonMiddle;
	MouseButtonOther(name : String);
}

typedef MouseButtonEventData =
{
	var button : MouseButton;
	var newState : MouseButtonState; 
}

typedef MouseMovementEventData =
{
	var deltaX : Float;
	var deltaY : Float; 
}
