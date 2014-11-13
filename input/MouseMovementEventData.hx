package input;

/// not yet used
class MouseMovementEventData
{
    public var deltaX(default, default) : Float; 
    public var deltaY(default, default) : Float;

    public function new() 
    {
    	deltaX = 0;
    	deltaY = 0;
    };

    public function copy(origin: MouseMovementEventData): Void
    {
        deltaX = origin.deltaX;
        deltaY = origin.deltaY;
    }
}