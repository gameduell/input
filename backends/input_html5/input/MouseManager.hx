package input;

import types.MouseEvent;
import types.Touch;

import input.Mouse;

import msignal.Signal;

import js.JQuery;

import js.Browser;

@:access(input.Mouse)
class MouseManager
{
	private static var mouseInstance : MouseManager;

	private var mainMouse : Mouse;
	public var onTouches : Signal1<Array<Touch>>;
	private var mouses : Map<String, Mouse>;
	private var canvas : JQuery;
	private var CANVAS_ID : String = "#duell-view";
	private var jquery : JQuery;
	private function new()
	{
		mainMouse = new Mouse();
		mouses = new Map();
		onTouches = new Signal1();
		jquery = new JQuery(Browser.window);

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

	public static inline function instance() : MouseManager
	{
		return mouseInstance;
	}

	public static function initialize(finishedCallback : Void -> Void) : Void
	{
		mouseInstance = new MouseManager();		

		mouseInstance.jquery.ready(function(e):Void {
				
				mouseInstance.jquery.click(function(e:Dynamic){
					mouseInstance.mainMouse.screenPosition.x = e.pageX;
					mouseInstance.mainMouse.screenPosition.y = e.pageY;
					mouseInstance.mainMouse.onButtonEvent.dispatch({button : MouseButton.MouseButtonLeft, newState : MouseButtonState.MouseButtonStateDown});
				});

			finishedCallback();
		});

	}
}

