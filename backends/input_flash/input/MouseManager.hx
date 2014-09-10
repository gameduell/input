package input;

import types.MouseEvent;

import input.Mouse;

import msignal.Signal;

import flash.display.Stage;

@:access(input.Mouse)
class MouseManager
{
	private static var managerInstance : MouseManager;

	private var mainMouse : Mouse;
	private var mouses : Map<String, Mouse>;
	private var stage:Stage = flash.Lib.current.stage;
	private function new()
	{
		mainMouse = new Mouse();
		mouses = new Map();
	}

	public function getMainMouse() : Mouse
	{
		return mainMouse;
	}

	public function getMouse(mouseIdentifier : String) : Mouse
	{
		return mouses[mouseIdentifier];
	}

	public function getMouses() : Iterator<String>
	{
		return mouses.keys();
	}

	static public inline function instance() : MouseManager
	{
		return managerInstance;
	}

	public static function initialize(finishedCallback : Void -> Void) : Void
	{
		managerInstance = new MouseManager();
		managerInstance.stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, function(event : flash.events.MouseEvent){
			trace("Stage Clicked");
			managerInstance.mainMouse.screenPosition.x = managerInstance.stage.mouseX;
			managerInstance.mainMouse.screenPosition.y = managerInstance.stage.mouseY;
			managerInstance.mainMouse.onButtonEvent.dispatch({button : MouseButton.MouseButtonLeft, newState : MouseButtonState.MouseButtonStateDown});
		});

		finishedCallback();
	}
}

