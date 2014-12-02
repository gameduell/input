package input;

class KeyboardEventData
{
    public var keyCode: Int;

    public var shiftKeyPressed: Bool;
    public var ctrlKeyPressed: Bool;
    public var altKeyPressed: Bool;

    public var state: KeyState;

    public function new()
    {
        keyCode = 0;
        shiftKeyPressed = false;
        ctrlKeyPressed = false;
        altKeyPressed = false;
        state = null;
    }

    public function copy(origin: KeyboardEventData): Void
    {
        keyCode = origin.keyCode;
        shiftKeyPressed = origin.shiftKeyPressed;
        ctrlKeyPressed = origin.ctrlKeyPressed;
        altKeyPressed = origin.altKeyPressed;
        state = origin.state;
    }
}
