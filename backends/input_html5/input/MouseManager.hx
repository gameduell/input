package input;

import types.MouseEvent;

import input.Mouse;

import msignal.Signal;

@:access(input.Mouse)
class MouseManager
{
	static private var mouseInstance : MouseManager;

	private var mainMouse : Mouse;
	private var mouses : Map<String, Mouse>;

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
		return mouseInstance;
	}

	public static function initialize(finishedCallback : Void -> Void) : Void
	{
		mouseInstance = new MouseManager();

		finishedCallback();
	}
}

