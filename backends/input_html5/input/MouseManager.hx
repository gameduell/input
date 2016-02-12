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

typedef MouseDownCoordinates = {
    var x : Int;
    var y : Int;
}

@:access(input.Mouse)
class MouseManager
{
    private static inline var MAX_CLICK_MOVE_DISTANCE: Int = 10;
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
        var canvasWidth: Int = canvas.width();
        var canvasHeight: Int = canvas.height();
        var canvasContext: Element = canvas.context;
        var downCoordinates: Map<MouseButton, MouseDownCoordinates> = new Map<MouseButton, MouseDownCoordinates>();
        var inside: Bool = false;

        jquery.ready(function(e):Void
        {
            jquery.mousedown(function(e:Dynamic)
            {
                var button: MouseButton = getButton(e.button);
                if (e.toElement == canvasContext)
                {
                    inside = true;
                    downCoordinates[button] = {x: Std.int(e.pageX - canvas.offset().left), y: Std.int(e.pageY - canvas.offset().top)};
                    mouseButtonEventData.button = button;
                    mouseButtonEventData.newState = MouseButtonState.MouseButtonStateDown;
                    mainMouse.state[button] = MouseButtonState.MouseButtonStateDown;
                    mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
                }
                else
                {
                    downCoordinates[button] = null;
                }
            });

            jquery.mousemove(function(e) : Void
            {
                if (inside)
                {
                    var calculatedScreenPositionX: Int = e.pageX - canvas.offset().left;
                    var calculatedScreenPositionY: Int = e.pageY - canvas.offset().top;
                    mouseMovementEventData.deltaX = calculatedScreenPositionX - Std.int(mainMouse.screenPosition.x);
                    mouseMovementEventData.deltaY = calculatedScreenPositionY - Std.int(mainMouse.screenPosition.y);
                    mainMouse.screenPosition.x = calculatedScreenPositionX;
                    mainMouse.screenPosition.y = calculatedScreenPositionY;
                    mainMouse.onMovementEvent.dispatch(mouseMovementEventData);
                }
            });

            jquery.mouseup(function(e:Dynamic)
            {
                var button: MouseButton = getButton(e.button);

                if (downCoordinates[button] != null)
                {
                    mouseButtonEventData.button = button;
                    if (inside)
                    {
                        // up
                        mouseButtonEventData.newState = MouseButtonState.MouseButtonStateUp;
                        mainMouse.state[button] = MouseButtonState.MouseButtonStateUp;
                        mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
                    }
                    else
                    {
                        // release outside
                        mouseButtonEventData.newState = MouseButtonState.MouseButtonStateReleaseOutside;
                        mainMouse.state[button] = MouseButtonState.MouseButtonStateReleaseOutside;
                        mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
                    }
                }

                downCoordinates[button] == null;
            });

			jquery.click(function(e:Dynamic)
			{
                var button: MouseButton = getButton(e.button);
                if (inside && downCoordinates[button] != null &&
                    getDistance(downCoordinates[button].x, downCoordinates[button].y,
                        Std.int(e.pageX - canvas.offset().left), Std.int(e.pageY - canvas.offset().top)) <= MAX_CLICK_MOVE_DISTANCE)
                {
                    mouseButtonEventData.newState = MouseButtonState.MouseButtonStateClick;
                    mainMouse.state[button] = MouseButtonState.MouseButtonStateClick;
                    mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
                    mainMouse.state[button] = MouseButtonState.MouseButtonStateUp;
                }
			});

            jquery.dblclick(function(e:Dynamic)
            {
                if (inside)
                {
                    var button: MouseButton = getButton(e.button);
                    mouseButtonEventData.button = button;
                    mouseButtonEventData.newState = MouseButtonState.MouseButtonStateDoubleClick;
                    mainMouse.state[button] = MouseButtonState.MouseButtonStateDoubleClick;
                    mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
                    mainMouse.state[button] = MouseButtonState.MouseButtonStateUp;
                }
            });

            jquery.mouseenter(function(e:Dynamic)
            {
                if (canvasContext == e.toElement)
                {
                    inside = true;
                }
            });

            jquery.mouseleave(function(e:Dynamic)
            {
                if (canvasContext == e.fromElement)
                {
                    inside = false;
                }
            });

            var mouseWheelHandler : Dynamic -> Void = function (e: Dynamic): Void
            {
                if (inside)
                {
                    e.preventDefault();
                    var wheelDelta: Float = 0.0;

                    if(untyped Browser.window.event)
                    {
                        untyped e = Browser.window.event;
                    }

                    if(untyped e.wheelDelta)
                    {
                        wheelDelta = e.wheelDelta / 120.0;
                    }
                    else
                    {
                        wheelDelta = -e.detail / 3.0;
                    }
                    mouseButtonEventData.button = MouseButton.MouseButtonWheel(wheelDelta);
                    mouseButtonEventData.newState = MouseButtonState.MouseButtonStateNone;
                    mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
                }
            };


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

    private static inline function getButton(id: Int): MouseButton
    {
        switch (id)
        {
            case 0:
                return MouseButton.MouseButtonLeft;
            case 1:
                return MouseButton.MouseButtonMiddle;
            case 2:
                return MouseButton.MouseButtonRight;
            default:
                return MouseButton.MouseButtonOther('button$id');
        }
    }

    private static inline function getDistance(ax: Int, ay: Int, bx: Int, by: Int): Int
    {
        return Std.int(Math.sqrt(Math.pow(ax - bx, 2) + Math.pow(ay - by, 2)));
    }
}
