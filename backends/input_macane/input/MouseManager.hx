package input;


import input.Mouse;
import input.MouseEventData;

import msignal.Signal;

@:access(input.Mouse)
class MouseManager
{
	private static var managerInstance : MouseManager;

	private var mainMouse : EditorMouse;
	private var mouses : Map<String, Mouse>;
	private function new()
	{
		mainMouse = new FlashMouse();
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
		finishedCallback();
	}
}

