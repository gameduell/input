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
		stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, function(event : flash.events.MouseEvent)
		{
			mouseButtonEventData.button = MouseButton.MouseButtonLeft;
			mouseButtonEventData.newState = MouseButtonState.MouseButtonStateDown;
			mainMouse.state[MouseButton.MouseButtonLeft] = MouseButtonState.MouseButtonStateDown;
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

        stage.addEventListener(flash.events.MouseEvent.MOUSE_UP, function(event : flash.events.MouseEvent)
		{
			mouseButtonEventData.button = MouseButton.MouseButtonLeft;
			mouseButtonEventData.newState = MouseButtonState.MouseButtonStateUp;
			mainMouse.state[MouseButton.MouseButtonLeft] = MouseButtonState.MouseButtonStateUp;
            mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
        });


		stage.addEventListener(flash.events.MouseEvent.CLICK, function(event : flash.events.MouseEvent)
		{
			mouseButtonEventData.button = MouseButton.MouseButtonLeft;
			mouseButtonEventData.newState = MouseButtonState.MouseButtonStateClick;
			mainMouse.state[MouseButton.MouseButtonLeft] = MouseButtonState.MouseButtonStateClick;
			mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
			mainMouse.state[MouseButton.MouseButtonLeft] = MouseButtonState.MouseButtonStateUp;
		});

		stage.doubleClickEnabled=true;
		stage.addEventListener(flash.events.MouseEvent.DOUBLE_CLICK, function(event : flash.events.MouseEvent)
		{
			mouseButtonEventData.button = MouseButton.MouseButtonLeft;
			mouseButtonEventData.newState = MouseButtonState.MouseButtonStateDoubleClick;
			mainMouse.state[MouseButton.MouseButtonLeft] = MouseButtonState.MouseButtonStateDoubleClick;
			mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
			mainMouse.state[MouseButton.MouseButtonLeft] = MouseButtonState.MouseButtonStateUp;
		});

		stage.addEventListener(flash.events.MouseEvent.MOUSE_WHEEL, function(event : flash.events.MouseEvent)
		{
			var wheelDelta: Float = cast event.delta;
			mouseButtonEventData.button = MouseButton.MouseButtonWheel(wheelDelta);
			mouseButtonEventData.newState = MouseButtonState.MouseButtonStateNone;
			mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
		});

		finishedCallback();
	}
}
