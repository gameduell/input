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
    Representation of the keyboard event data.
 */
class KeyboardEventData
{
    /** Key code. */
    public var keyCode: Int;

    /** Shift key pressed. */
    public var shiftKeyPressed: Bool;

    /** Ctrl key pressed. */
    public var ctrlKeyPressed: Bool;

    /** Alt key pressed. */
    public var altKeyPressed: Bool;

    /** Caps key pressed. */
    public var capsKeyPressed: Bool;

    /** The key state. */
    public var state: KeyState;

    /**
        Constructor, initializes all the fields.
     */
    public function new()
    {
        keyCode = 0;
        shiftKeyPressed = false;
        ctrlKeyPressed = false;
        altKeyPressed = false;
        capsKeyPressed = false;
        state = null;
    }

    /**
        Creates a copy of the keyboard event data.

        @param origin KeyboardEventData to copy
     */
    public function copy(origin: KeyboardEventData): Void
    {
        keyCode = origin.keyCode;
        shiftKeyPressed = origin.shiftKeyPressed;
        ctrlKeyPressed = origin.ctrlKeyPressed;
        altKeyPressed = origin.altKeyPressed;
        capsKeyPressed = origin.capsKeyPressed;
        state = origin.state;
    }
}
