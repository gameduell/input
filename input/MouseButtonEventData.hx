package input;

import input.MouseButtonState;
import input.MouseButton;

/// WARNING, these objects are short lived, and unless they are used on the same frame where
/// they are dispatched, they should have its contents copied
class MouseButtonEventData
{
    public var button(default, default) : MouseButton; 
    public var newState(default, default) : MouseButtonState;

    public function new() 
    {
    	button = null;
    	newState = null;
    };

    public function copy(origin: MouseButtonEventData): Void
    {
        button = origin.button;
        newState = origin.newState;
    }
}