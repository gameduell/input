## Description

This library gives an input handling API for flash, html5, iOS and Android.
The input types it provides are touch, mouse and keyboard.

## Usage:

There are 3 singletons, one for each of the input types: MouseManager, TouchManager and KeyboardManager.
In order to use any of these components, the Manager must be initialized.

### Specifics per Platform:

#### iOS
For the TouchManager to work on iOS, another library has to have initialized a view. When the TouchManager initializes it will attach itself to the current top most view.

### Examples
The following sample code can be found within the input test project.

#### Initialization
```
MouseManager.initialize(function() 
{
    KeyboardManager.initialize(function() 
    {
        TouchManager.initialize(function() 
        {
            VirtualInputManager.initialize(function() {
                // start app
            });
        });
    });
});
```

#### Keyboard event
```
KeyboardManager.instance().getMainKeyboard().onKeyboardEvent.add(function(keyeventdata: KeyboardEventData)
{
    switch (keyeventdata.state)
    {
        case KeyState.Down:
            {
                if (keyeventdata.shiftKeyPressed)
                {
                    trace("Shift key pressed");
                }
                else
                {
                    trace("Any key pressed");
                }
            }
        case KeyState.Up:
            {
                trace("Key up");
            }
    }
});
```

#### Mouse button
```
MouseManager.instance().getMainMouse().onButtonEvent.add(function(eventData: MouseButtonEventData)
{
    var state: String = mouseButtonState(eventData.newState);
    switch (eventData.button)
    {
        case MouseButton.MouseButtonLeft:
            {
                trace('Mouse: MouseButtonLeft, $state');
            }
        case MouseButton.MouseButtonRight:
            {
                trace('Mouse: MouseButtonRight, $state');
            }
        case MouseButton.MouseButtonMiddle:
            {
                trace('Mouse: MouseButtonMiddle, $state');
            }
        case MouseButton.MouseButtonWheel:
            {
                trace('Mouse: MouseButtonWheel, $state');
            }
        case MouseButton.MouseButtonOther:
            {
                trace('Mouse: MouseButtonOther, $state');
            }
    }
});

private function mouseButtonState(state : MouseButtonState) : String
{
    switch (state)
    {
        case MouseButtonState.MouseButtonStateClick:
            return "Click";

        case MouseButtonState.MouseButtonStateDoubleClick:
            return "DoubleClick";

        case MouseButtonState.MouseButtonStateDown:
            return "Down";

        case MouseButtonState.MouseButtonStateNone:
            return "None";

        case MouseButtonState.MouseButtonStateUp:
            return "Up";
    }
}
```

#### Mouse movement
```
MouseManager.instance().getMainMouse().onMovementEvent.add(function(eventData: MouseMovementEventData)
{
    var deltaX: Float = eventData.deltaX;
    var deltaY: Float = eventData.deltaY;
    var posX: Float = MouseManager.instance().getMainMouse().screenPosition.x;
    var posY: Float = MouseManager.instance().getMainMouse().screenPosition.y;
    trace('Mouse: MouseMovement ($deltaX, $deltaY) - ($posX, $posY)');
});
```

#### Touch
```
private var touchNumber: Int = 0;

TouchManager.instance().onTouches.add(function(touchEventArray : Array<Touch>)
{
    for (touch in touchEventArray) {
        var id: Int = touch.id;
        var x: Int = touch.x;
        var y: Int = touch.y;
        var state: String = touchState(touch.state);

        if (touch.state == TouchState.TouchStateBegan) {
            touchNumber++;
        } else if (touch.state == TouchState.TouchStateEnded ||
                touch.state == TouchState.TouchStateCancelled) {
            if (touchNumber > 0) {
                if (touchNumber == 2) {
                    // do something after touching with two fingers
                }

                touchNumber--;
            }
        }

        trace('Touch [$id] $state ($x, $y), $touchNumber touches');
    }
});

private function touchState(state : TouchState) : String
{
    switch (state)
    {
        case TouchState.TouchStateBegan:
            return "Began";

        case TouchState.TouchStateMoved:
            return "Moved";

        case TouchState.TouchStateStationary:
            return "Stationary";

        case TouchState.TouchStateEnded:
            return "Ended";

        case TouchState.TouchStateCancelled:
            return "Cancelled";
    }
}
```

#### Virtual input
```
private var virtualInputVisible: Bool = false;

VirtualInputManager.instance().getVirtualInput().onInputStarted.add(function() {
    virtualInputVisible = true;
    trace('Input started');
});

VirtualInputManager.instance().getVirtualInput().onTextChanged.add(function(string: String) {
    trace('Text changed: $string');
});

VirtualInputManager.instance().getVirtualInput().onInputEnded.add(function() {
    virtualInputVisible = false;
    trace('Input ended');
});

private function toggleVirtualInput() {
    if (virtualInputVisible == true) {
        VirtualInputManager.instance().hide();
    } else {
        VirtualInputManager.instance().show();
    }
}
```