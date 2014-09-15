package input;
import input.Mouse;
import types.Vector2;
class FlashMouse extends Mouse
{

	public function new()
	{
		super();	
	}

	override public function get_screenPosition() : Vector2
	{
		_screenPosition.x = flash.Lib.current.stage.mouseX;
		_screenPosition.y = flash.Lib.current.stage.mouseY;
	    return _screenPosition;
	}

}