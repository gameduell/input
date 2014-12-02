package input;

import msignal.Signal.Signal1;

class Keyboard
{
    public var onKeyboardEvent(default, null): Signal1<KeyboardEventData>;

    public function new()
    {
        onKeyboardEvent = new Signal1();
    }
}