package input;

import input.Mouse;

import js.JQuery;

import js.Browser;
import input.Mouse;
import input.MouseButtonEventData;

@:access(input.Mouse)
class MouseManager
{
	private static var mouseInstance : MouseManager;

	private var mainMouse : Mouse;
	private var mouses : Map<String, Mouse>;
	private var mouseButtonEventData: MouseButtonEventData;
	private var mouseMovementEventData: MouseMovementEventData;
	private var jquery : JQuery;
	private function new()
	{
		mainMouse = new Mouse();
		mouses = new Map();
		jquery = new JQuery(Browser.window);
		mouseButtonEventData = new MouseButtonEventData();
		mouseMovementEventData = new MouseMovementEventData();
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

		mouseInstance.initializeCallbacks(finishedCallback);
	}

	private function initializeCallbacks(finishedCallback : Void -> Void)
	{
		jquery.ready(function(e):Void
        {
            jquery.mousedown(function(e:Dynamic){
            	mouseButtonEventData.button = MouseButton.MouseButtonLeft;
            	mouseButtonEventData.newState = MouseButtonState.MouseButtonStateDown;
                mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
            });

			jquery.mousemove(function(e) : Void
			{
				mouseMovementEventData.deltaX = e.pageX - mainMouse.screenPosition.x;
				mouseMovementEventData.deltaY = e.pageY - mainMouse.screenPosition.y;
				mainMouse.screenPosition.x = e.pageX;
				mainMouse.screenPosition.y = e.pageY;
				mainMouse.onMovementEvent.dispatch(mouseMovementEventData);
			});

            jquery.mouseup(function(e:Dynamic)
			{
            	mouseButtonEventData.button = MouseButton.MouseButtonLeft;
            	mouseButtonEventData.newState = MouseButtonState.MouseButtonStateUp;
                mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
            });

			jquery.click(function(e:Dynamic)
			{
				mouseButtonEventData.button = MouseButton.MouseButtonLeft;
				mouseButtonEventData.newState = MouseButtonState.MouseButtonStateClick;
				mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
			});

			jquery.dblclick(function(e:Dynamic)
			{
				mouseButtonEventData.button = MouseButton.MouseButtonLeft;
				mouseButtonEventData.newState = MouseButtonState.MouseButtonStateDoubleClick;
				mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
			});

			/// Mousewheel Events
			if (untyped Browser.window.addEventListener) 
			{
				// IE9, Chrome, Safari, Opera
				untyped Browser.window.addEventListener("mousewheel", mouseWheelHandler, false);
				// Firefox
				untyped Browser.window.addEventListener("DOMMouseScroll", mouseWheelHandler, false);
			}
			else 
			{	// IE 6/7/8
				untyped Browser.window.attachEvent("onmousewheel", mouseWheelHandler);		
			}	   

			finishedCallback();
		});
	}

	private function mouseWheelHandler(e: Dynamic): Void
	{
		e.preventDefault();

		var wheelDelta: Float = 0.0;

		if(untyped Browser.window.event)
		{
			e = Browser.window.event;
		}

		if(untyped e.wheelDelta)
		{
			wheelDelta = cast e.wheelDelta/120;
		}
		else
		{
			wheelDelta = cast -e.detail/3;
		}

		mouseButtonEventData.button = MouseButton.MouseButtonWheel(wheelDelta);
		mouseButtonEventData.newState = MouseButtonState.MouseButtonStateNone;
		mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
	}
}

