/**
* Created by Julián Mancera
**/

package;

import input.VirtualInputManager;
import msignal.Signal.Signal0;
import input.TouchManager;
import input.KeyboardManager;
import input.MouseManager;
import graphics.Graphics;
import input.Touch;
import input.MouseMovementEventData;
import input.MouseButtonState;
import input.MouseButton;
import input.MouseButtonEventData;
import input.KeyState;
import input.KeyboardEventData;
import runloop.RunLoop;
import runloop.MainRunLoop;

class Main
{
	/// callbacks
	public var onEnterFrame(default, null): Signal0 = new Signal0();
	public var onRender(default, null): Signal0 = new Signal0();
	public var onExitFrame(default, null): Signal0 = new Signal0();

	/// runloop
	public var loopTheMainLoopOnRender: Bool = true;
	public var mainLoop : MainRunLoop = RunLoop.getMainLoop();

	/// graphics
	public var clearAndPresentDefaultBuffer: Bool = true;

	private var touchNumber: Int = 0;
	private var virtualInputVisible: Bool = false;

	public function new()
	{
		trace("Input Test");

		Graphics.initialize(function()
		{
			#if (html5)
			MouseManager.initialize(function()
			{
				KeyboardManager.initialize(function()
				{
			#end
					TouchManager.initialize(function()
					{
						VirtualInputManager.initialize(function() {
							startApp();
						});
					});
			#if (html5)
				});
			});
			#end
		});
	}

	private function startApp() : Void
	{
		// Graphics, required to solve the flashing screen on Android
		Graphics.instance().onRender.add(performOnRender);

		// Keyboard
		#if (html5)
		KeyboardManager.instance().getMainKeyboard().onKeyboardEvent.add(function(keyeventdata: KeyboardEventData)
		{
			switch (keyeventdata.state)
			{
				case KeyState.Down:
					{
						if (keyeventdata.shiftKeyPressed)
						{
							trace("Shift key down");
						}
						else
						{
							trace("Any key down");
						}
					}
				case KeyState.Up:
					{
						trace("Key up: " + keyeventdata.keyCode);
					}
				case KeyState.Press:
					{
						trace("Key press: " + keyeventdata.charCode + " = " + String.fromCharCode(keyeventdata.charCode));
					}
			}
		});
		#end

		// Mouse button
		#if (html5)
		MouseManager.instance().getMainMouse().onButtonEvent.add(function(mouseButtonEventData: MouseButtonEventData)
		{
			var state: String = mouseButtonState(mouseButtonEventData.newState);
			switch (mouseButtonEventData.button)
			{
				case MouseButton.MouseButtonLeft:
					{
						trace('Mouse: MouseButtonLeft, $state');
					}
				case MouseButton.MouseButtonRight:
					{
						trace('Mouse: MouseButtonRight, $state');
					}
				case MouseButton.MouseButtonMiddle:
					{
						trace('Mouse: MouseButtonMiddle, $state');
					}
				case MouseButton.MouseButtonWheel:
					{
						trace('Mouse: MouseButtonWheel, delta=${mouseButtonEventData.button}');
					}
				case MouseButton.MouseButtonOther:
					{
						trace('Mouse: MouseButtonOther, $state');
					}
			}
		});
		#end

		// Mouse movement
		#if (html5)
		MouseManager.instance().getMainMouse().onMovementEvent.add(function(mouseMovementEventData: MouseMovementEventData)
		{
			var deltaX: Float = mouseMovementEventData.deltaX;
			var deltaY: Float = mouseMovementEventData.deltaY;
			var posX: Float = MouseManager.instance().getMainMouse().screenPosition.x;
			var posY: Float = MouseManager.instance().getMainMouse().screenPosition.y;
			trace('Mouse: MouseMovement ($deltaX, $deltaY) - ($posX, $posY)');
		});
		#end

		// Touch
		TouchManager.instance().onTouches.add(function(touchEventArray : Array<Touch>)
		{
			for (touch in touchEventArray) {
				var id: Int = touch.id;
				var x: Int = touch.x;
				var y: Int = touch.y;
				var state: String = touchState(touch.state);

				if (touch.state == TouchState.TouchStateBegan) {
					touchNumber++;
				} else if (touch.state == TouchState.TouchStateEnded ||
						touch.state == TouchState.TouchStateCancelled) {
					if (touchNumber > 0) {
						// toggle the virtual input after touching the screen with two fingers
						if (touchNumber == 2) {
							toggleVirtualInput();
						}

						touchNumber--;
					}
				}

				trace('Touch [$id] $state ($x, $y), $touchNumber touches');
			}
		});

		// Virtual input
		VirtualInputManager.instance().getVirtualInput().onInputStarted.add(function() {
			virtualInputVisible = true;
			trace('Input started');
		});

		VirtualInputManager.instance().getVirtualInput().onTextChanged.add(function(string: String) {
			trace('Text changed: $string');
		});

		VirtualInputManager.instance().getVirtualInput().onInputEnded.add(function() {
			virtualInputVisible = false;
			trace('Input ended');
		});
	}

	// Display Sync
	private function performOnRender(): Void
	{
		try
		{
			// Input Processing in here
			onEnterFrame.dispatch();

			if (loopTheMainLoopOnRender)
			{
				// Mainloop, runs the timers, delays and async executions
				mainLoop.loopMainLoop();
			}

			// Rendering
			if (clearAndPresentDefaultBuffer)
			{
				Graphics.instance().clearAllBuffers();
			}

			onRender.dispatch();

			if (clearAndPresentDefaultBuffer)
			{
				Graphics.instance().present();
			}

			onExitFrame.dispatch();
		}
		catch(e : Dynamic)
		{
			trace("error onRender");
		}
	}

	private function mouseButtonState(state : MouseButtonState) : String
	{
		switch (state)
		{
			case MouseButtonState.MouseButtonStateClick:
				return "Click";

			case MouseButtonState.MouseButtonStateDoubleClick:
				return "DoubleClick";

			case MouseButtonState.MouseButtonStateDown:
				return "Down";

			case MouseButtonState.MouseButtonStateNone:
				return "None";

			case MouseButtonState.MouseButtonStateUp:
				return "Up";

			case MouseButtonState.MouseButtonStateReleaseOutside:
				return "Outside";
		}
	}

	private function touchState(state : TouchState) : String
	{
		switch (state)
		{
			case TouchState.TouchStateBegan:
				return "Began";

			case TouchState.TouchStateMoved:
				return "Moved";

			case TouchState.TouchStateStationary:
				return "Stationary";

			case TouchState.TouchStateEnded:
				return "Ended";

			case TouchState.TouchStateCancelled:
				return "Cancelled";
		}
	}

	private function toggleVirtualInput() {
		if (virtualInputVisible == true) {
			VirtualInputManager.instance().hide();
		} else {
			VirtualInputManager.instance().show();
		}
	}

	/// MAIN
	static var _main : Main;
	static function main() : Void
	{
		_main = new Main();
	}
}