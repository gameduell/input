package input;

enum TouchState
{
	TouchStateBegan;
	TouchStateMoved;
	TouchStateStationary;
	TouchStateEnded;
    TouchStateCancelled;
}

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
}