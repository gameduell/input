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

import input.MouseButtonEventData;
import input.MouseButton;
import input.MouseButtonState;

import types.Vector2;

import msignal.Signal;

/**
    Representation of a mouse that listens to mouse events.
 */
class Mouse
{
	/**
        Retrieves the state of the mouse.
     */
	public var state (default, null) : Map<MouseButton, MouseButtonState>;

	/**
        Dispatched when the mouse generates a button event.
     */
	public var onButtonEvent(default, null) : Signal1<MouseButtonEventData>;

	/**
        Dispatched when the mouse generates a movement event.
     */
	public var onMovementEvent(default, null) : Signal1<MouseMovementEventData>;

	/**
        Retrieves the screen position.
     */
	public var screenPosition(default, null) : Vector2;

    /**
        Retrieves whether or not the mouse cursor is within the bounds of the scene.
     */
    public var inside(default, default): Bool = false;

    /**
        If set to true the mouse will use pointer (hand) instead of default cursor.
     */
	public var usePointerCursor(default, set): Bool = false;

	/**
        Dispatched when the usePointerCursor is changed.
     */
	public var onCursorChange(default, null) : Signal1<Mouse>;

	/**
        Called from within the package, should not be created from the outside.
     */
	private function new()
	{
		state = [
			MouseButtonLeft => MouseButtonStateUp,
			MouseButtonRight => MouseButtonStateUp,
			MouseButtonMiddle => MouseButtonStateUp
		];
		onButtonEvent = new Signal1();
		onMovementEvent = new Signal1();
		screenPosition = new Vector2();
		onCursorChange = new Signal1();
	}

	private function get_screenPosition() : Vector2
	{
	    return screenPosition;
	}

	private function set_usePointerCursor(v: Bool): Bool
	{
		if (v != usePointerCursor)
		{
			usePointerCursor = v;
			onCursorChange.dispatch(this);
		}
		return v;
	}
}
