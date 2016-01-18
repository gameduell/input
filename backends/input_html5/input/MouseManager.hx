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

import js.JQuery;
import js.html.Element;
import input.Mouse;

import js.JQuery;

import js.Browser;
import input.Mouse;
import input.MouseButtonEventData;
import html5_appdelegate.HTML5AppDelegate;

@:access(input.Mouse)
class MouseManager
{
	private static var mouseInstance : MouseManager;

	private var mainMouse : Mouse;
	private var mouses : Map<String, Mouse>;
	private var mouseButtonEventData: MouseButtonEventData;
	private var mouseMovementEventData: MouseMovementEventData;
	private var jquery : JQuery;
	private var canvas : JQuery;

	private function new()
	{
		mainMouse = new Mouse();
		mouses = new Map();
		jquery = new JQuery(Browser.window);
		canvas = new JQuery(HTML5AppDelegate.instance().rootView);

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
				mainMouse.state[MouseButton.MouseButtonLeft] = MouseButtonState.MouseButtonStateDown;
                mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
      });

			jquery.mousemove(function(e) : Void
			{
				mouseMovementEventData.deltaX = e.pageX - mainMouse.screenPosition.x;
				mouseMovementEventData.deltaY = e.pageY - mainMouse.screenPosition.y;
				mainMouse.screenPosition.x = e.pageX - canvas.offset().left;
				mainMouse.screenPosition.y = e.pageY - canvas.offset().top;
				mainMouse.onMovementEvent.dispatch(mouseMovementEventData);
			});

      jquery.mouseup(function(e:Dynamic)
			{
            	mouseButtonEventData.button = MouseButton.MouseButtonLeft;
            	mouseButtonEventData.newState = MouseButtonState.MouseButtonStateUp;
				mainMouse.state[MouseButton.MouseButtonLeft] = MouseButtonState.MouseButtonStateUp;
                mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
      });

			jquery.click(function(e:Dynamic)
			{
				mouseButtonEventData.button = MouseButton.MouseButtonLeft;
				mouseButtonEventData.newState = MouseButtonState.MouseButtonStateClick;
				mainMouse.state[MouseButton.MouseButtonLeft] = MouseButtonState.MouseButtonStateClick;
				mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
				mainMouse.state[MouseButton.MouseButtonLeft] = MouseButtonState.MouseButtonStateUp;
			});

			jquery.dblclick(function(e:Dynamic)
			{
				mouseButtonEventData.button = MouseButton.MouseButtonLeft;
				mouseButtonEventData.newState = MouseButtonState.MouseButtonStateDoubleClick;
				mainMouse.state[MouseButton.MouseButtonLeft] = MouseButtonState.MouseButtonStateDoubleClick;
				mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
				mainMouse.state[MouseButton.MouseButtonLeft] = MouseButtonState.MouseButtonStateUp;
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
		var wheelDelta: Float = 0.0;

		if(untyped Browser.window.event)
		{
			untyped e = Browser.window.event;
		}

		if(untyped e.wheelDelta)
		{
			wheelDelta = Std.int(e.wheelDelta / 120.0);
		}
		else
		{
			wheelDelta = Std.int(-e.detail / 3.0);
		}

		mouseButtonEventData.button = MouseButton.MouseButtonWheel(wheelDelta);
		mouseButtonEventData.newState = MouseButtonState.MouseButtonStateNone;
		mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
	}
}
