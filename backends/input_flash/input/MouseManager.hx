package input;

import types.MouseEvent;

import input.Mouse;

import msignal.Signal;

@:access(input.Mouse)
class MouseManager
{
	static private var instance : MouseManager;

	private var mainMouse : Mouse;
	private var mouses : Map<String, Mouse>;

	private function new()
	{
		mainMouse = new Mouse();
		mouses = new Map();
	}

	public static function getMainMouse() : Mouse
	{
		return mainMouse;
	}

	public static function getMouse(mouseIdentifier : String) : Mouse
	{
		return mouses[mouseIdentifier];
	}

	public static function getMouses() : Iterator<String>
	{
		return mouses.keys();
	}

	static public inline function instance() : MouseManager
	{
		return instance;
	}

	public static function initialize(finishedCallback : Void -> Void) : Void
	{
		instance = new MouseManager();

		finishedCallback();
	}
}

