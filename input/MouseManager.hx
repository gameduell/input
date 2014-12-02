package input;

import input.Mouse;

extern class MouseManager
{
	private function new();

	static public function instance() : MouseManager;

	public static function initialize(finishedCallback : Void->Void) : Void;

	public static function getMainMouse() : Mouse;

	/// maybe one day we will have support for multiple mouses :D
	public static function getMouse(mouseIdentifier : String) : Mouse;
	public static function getMouses() : Iterator<String>;
}
