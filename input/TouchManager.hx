package input;

import input.Mouse;

import msignal.Signal;

import types.Touch;

extern class TouchManager
{
	public var onTouches : Signal1<Array<Touch>>;

	private function new();

	static public function instance() : MouseManager;

	public static function initialize(finishedCallback : Void->Void) : Void
}
