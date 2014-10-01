package input;

enum MouseButtonState
{
    MouseButtonStateDown;
    MouseButtonStateUp;
    MouseButtonStateClick;
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
}
