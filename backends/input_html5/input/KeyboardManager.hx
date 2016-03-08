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

import js.html.KeyboardEvent;
import input.Keyboard;
import js.JQuery;
import js.Browser;
import input.KeyboardEventData;

@:access(input.Keyboard)
class KeyboardManager
{
	private static var keyboardInstance: KeyboardManager;

	private static var preventedKeys: Array<Int> = [KeyboardEvent.DOM_VK_BACK_SPACE,
	KeyboardEvent.DOM_VK_LEFT,
	KeyboardEvent.DOM_VK_UP,
	KeyboardEvent.DOM_VK_RIGHT,
	KeyboardEvent.DOM_VK_DOWN];

	private var mainKeyboard: Keyboard;

	private var keyboardEventData: KeyboardEventData;
	private var jquery: JQuery;

	private function new()
	{
		mainKeyboard = new Keyboard();
		jquery = new JQuery(Browser.window);
		keyboardEventData = new KeyboardEventData();
	}

	public function getMainKeyboard(): Keyboard
	{
		return mainKeyboard;
	}

	public static inline function instance(): KeyboardManager
	{
		return keyboardInstance;
	}

	public static function initialize(finishedCallback: Void -> Void) : Void
	{
		keyboardInstance = new KeyboardManager();

		keyboardInstance.initializeCallbacks(finishedCallback);
	}

	private function initializeCallbacks(finishedCallback: Void -> Void)
	{
		jquery.ready(function(e):Void
        {
			jquery.keydown(function(e:Dynamic): Bool
			{
				keyboardEventData.keyCode = e.which;
				keyboardEventData.shiftKeyPressed = e.shiftKey;
				keyboardEventData.ctrlKeyPressed = e.ctrlKey;
				keyboardEventData.altKeyPressed = e.altKey;
                keyboardEventData.capsKeyPressed = untyped CapsLock.isOn();
				keyboardEventData.state = KeyState.Down;
				mainKeyboard.onKeyboardEvent.dispatch(keyboardEventData);

                // Back space key is disabled as in the browsers it triggers history back action.
				return preventedKeys.indexOf(e.which) == -1;
			});

            jquery.keypress(function(e:Dynamic)
			{
				keyboardEventData.charCode = e.which;
				keyboardEventData.shiftKeyPressed = e.shiftKey;
				keyboardEventData.ctrlKeyPressed = e.ctrlKey;
				keyboardEventData.altKeyPressed = e.altKey;
				keyboardEventData.capsKeyPressed = untyped CapsLock.isOn();
				keyboardEventData.state = KeyState.Press;
				mainKeyboard.onKeyboardEvent.dispatch(keyboardEventData);

				// fixes issue on firefox
				e.preventDefault();
            });

			jquery.keyup(function(e:Dynamic)
			{
				keyboardEventData.keyCode = e.which;
				keyboardEventData.shiftKeyPressed = e.shiftKey;
				keyboardEventData.ctrlKeyPressed = e.ctrlKey;
				keyboardEventData.altKeyPressed = e.altKey;
				keyboardEventData.capsKeyPressed = untyped CapsLock.isOn();
				keyboardEventData.state = KeyState.Up;
				mainKeyboard.onKeyboardEvent.dispatch(keyboardEventData);
			});

			finishedCallback();
		});
	}
}
