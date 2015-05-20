/*
 * Copyright (c) 2003-2015, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
            keyboardEventData.capsKeyPressed = flash.ui.Keyboard.capsLock;
			keyboardEventData.state = KeyState.Down;
			mainKeyboard.onKeyboardEvent.dispatch(keyboardEventData);
		});

		stage.addEventListener(flash.events.KeyboardEvent.KEY_UP, function(event: flash.events.KeyboardEvent)
		{
			keyboardEventData.keyCode = event.keyCode;
			keyboardEventData.shiftKeyPressed = event.shiftKey;
			keyboardEventData.ctrlKeyPressed = event.ctrlKey;
			keyboardEventData.altKeyPressed = event.altKey;
            keyboardEventData.capsKeyPressed = flash.ui.Keyboard.capsLock;
			keyboardEventData.state = KeyState.Up;
			mainKeyboard.onKeyboardEvent.dispatch(keyboardEventData);
		});

		finishedCallback();
	}
}
