package input;

import msignal.Signal;

import input.Touch;

extern class TouchManager
{
	public var onTouches(default, null) : Signal1<Array<Touch>>;

	private function new();

	static public function instance() : TouchManager;

	public static function initialize(finishedCallback : Void->Void) : Void;
}
