package input;
import input.Mouse;
import types.Vector2;
class EditorMouse extends Mouse
{

	public function new()
	{
		super();	
	}

	public function setScreenPosition(position : Vector2):Void
	{
	    _screenPosition.x = position.x;
	    _screenPosition.y = position.y;
	}

}