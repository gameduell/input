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

/**
    Defines the state of a touch event.
 */
enum TouchState
{
    /** Touch began. */
	TouchStateBegan;

    /** Touch moved. */
	TouchStateMoved;

    /** Touch stationary. */
	TouchStateStationary;

    /** Touch ended. */
	TouchStateEnded;

    /** Touch cancelled. */
    TouchStateCancelled;
}

/**
    Representation of a Touch event data

    WARNING, these objects are short lived, and unless they are used on the same frame where
    they are dispatched, they should have its contents copied.
 */
class Touch
{
    /**
        Gets the id of the touch.
     */
    public var id(default, default) : Int;

    /**
        Gets the x position of the touch.
     */
    public var x(default, default) : Int;

    /**
        Gets the y position of the touch.
     */
    public var y(default, default) : Int;

    /**
        Gets the touch state.
     */
    public var state(default, default) : TouchState;

    /**
        Constructor, initializes all the fields.
     */
    public function new()
    {
    	id = 0;
    	x = 0;
    	y = 0;
    	state = TouchStateBegan;
    };

    /**
        Creates a copy of the touch

        @param origin Touch to copy
     */
    public function copy(origin: Touch): Void
    {
        x = origin.x;
        y = origin.y;
        state = origin.state;
        id = origin.id;
    }
}
