package input;

enum TouchState
{
	TouchStateBegan;
	TouchStateMoved;
	TouchStateStationary;
	TouchStateEnded;
    TouchStateCancelled;
}


/// WARNING, these objects are short lived, and unless they are used on the same frame where
/// they are dispatched, they should have its contents copied
class Touch
{
    public var id(default, default) : Int; 
    public var x(default, default) : Int;
    public var y(default, default) : Int;
    public var state(default, default) : TouchState;

    public function new() 
    {
    	id = 0;
    	x = 0;
    	y = 0;
    	state = TouchStateBegan;
    };

    public function copy(origin: Touch): Void
    {
        x = origin.x;
        y = origin.y;
        state = origin.state;
        id = origin.id;
    }
}