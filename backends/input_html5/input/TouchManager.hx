package input;

import input.Mouse;

import msignal.Signal;

import types.Touch;

class TouchManager
{
	public var onTouches : Signal1<Array<Touch>>;

	static private var touchInstance : TouchManager;
	private function new()
	{

	}

	static public function instance() : TouchManager
	{
		return touchInstance;
	}

	public static function initialize(finishedCallback : Void->Void) : Void
	{

	}
}