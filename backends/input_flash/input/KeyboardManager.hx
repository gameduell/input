package input;

import flash.events.KeyboardEvent;
import flash.Lib;
import flash.display.Stage;

import input.Keyboard;
import input.KeyboardEventData;

@:access(input.Keyboard)
class KeyboardManager
{
	private static var keyboardInstance : KeyboardManager;

	private var mainKeyboard : Keyboard;

	private var keyboardEventData: KeyboardEventData;
	private var stage: Stage = flash.Lib.current.stage;

	private function new()
	{
		mainKeyboard = new Keyboard();
		keyboardEventData = new KeyboardEventData();
	}

	public static inline function instance(): KeyboardManager
	{
		return keyboardInstance;
	}

	public function getMainKeyboard(): Keyboard
	{
		return mainKeyboard;
	}

	public static function initialize(finishedCallback: Void -> Void) : Void
	{
		keyboardInstance = new KeyboardManager();

		keyboardInstance.initializeCallbacks(finishedCallback);
	}

	private function initializeCallbacks(finishedCallback: Void -> Void)
	{
		stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, function(event: flash.events.KeyboardEvent)
		{
			keyboardEventData.keyCode = event.keyCode;
			keyboardEventData.shiftKeyPressed = event.shiftKey;
			keyboardEventData.ctrlKeyPressed = event.ctrlKey;
			keyboardEventData.altKeyPressed = event.altKey;
			keyboardEventData.state = KeyState.Down;
			mainKeyboard.onKeyboardEvent.dispatch(keyboardEventData);
		});

		stage.addEventListener(flash.events.KeyboardEvent.KEY_UP, function(event: flash.events.KeyboardEvent)
		{
			keyboardEventData.keyCode = event.keyCode;
			keyboardEventData.shiftKeyPressed = event.shiftKey;
			keyboardEventData.ctrlKeyPressed = event.ctrlKey;
			keyboardEventData.altKeyPressed = event.altKey;
			keyboardEventData.state = KeyState.Up;
			mainKeyboard.onKeyboardEvent.dispatch(keyboardEventData);
		});

		finishedCallback();
	}
}
