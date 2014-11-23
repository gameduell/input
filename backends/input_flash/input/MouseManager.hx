package input;

import input.Mouse;
import input.MouseButtonEventData;

import flash.Lib;
import flash.display.Stage;

@:access(input.Mouse)
class MouseManager
{
	private static var managerInstance : MouseManager;

	private var mainMouse: FlashMouse;
	private var mouses: Map<String, Mouse>;
	private var stage: Stage = flash.Lib.current.stage;

	private var mouseButtonEventData: MouseButtonEventData;
	private var mouseMovementEventData: MouseMovementEventData;
	private var oldX: Float = 0.0;
	private var oldY: Float = 0.0;

	private function new()
	{
		mainMouse = new FlashMouse();
		mouses = new Map();
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

	static public inline function instance() : MouseManager
	{
		return managerInstance;
	}

	public static function initialize(finishedCallback : Void -> Void) : Void
	{
		managerInstance = new MouseManager();

        managerInstance.initializeCallbacks(finishedCallback);
	}

	private function initializeCallbacks(finishedCallback : Void -> Void)
	{
		stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, function(event : flash.events.MouseEvent){
			mouseButtonEventData.button = MouseButton.MouseButtonLeft;
			mouseButtonEventData.newState = MouseButtonState.MouseButtonStateDown;
			mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
		});

		stage.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, function(event : flash.events.MouseEvent)
		{
			mouseMovementEventData.deltaX = flash.Lib.current.stage.mouseX - oldX;
			mouseMovementEventData.deltaY = flash.Lib.current.stage.mouseY - oldY;
			mainMouse.onMovementEvent.dispatch(mouseMovementEventData);
			oldX = flash.Lib.current.stage.mouseX;
			oldY = flash.Lib.current.stage.mouseY;
		});
		
        stage.addEventListener(flash.events.MouseEvent.MOUSE_UP, function(event : flash.events.MouseEvent){
			mouseButtonEventData.button = MouseButton.MouseButtonLeft;
			mouseButtonEventData.newState = MouseButtonState.MouseButtonStateUp;
            mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
        });


		stage.addEventListener(flash.events.MouseEvent.CLICK, function(event : flash.events.MouseEvent){
			mouseButtonEventData.button = MouseButton.MouseButtonLeft;
			mouseButtonEventData.newState = MouseButtonState.MouseButtonStateClick;
			mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
		});

		stage.doubleClickEnabled=true;
		stage.addEventListener(flash.events.MouseEvent.DOUBLE_CLICK, function(event : flash.events.MouseEvent){
			mouseButtonEventData.button = MouseButton.MouseButtonLeft;
			mouseButtonEventData.newState = MouseButtonState.MouseButtonStateDoubleClick;
			mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
		});

		finishedCallback();
	}
}

