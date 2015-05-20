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

package input.util;

import haxe.ds.Vector;
import input.KeyboardEventData;

@:final class KeyboardInputProcessor
{
    /**
        Processes the string input on `string` using the keyboard event data encoded in `data`, restricting the input
        according to the flags specified in `allowedCharCodes`.

        Returns the final input to `callback`.
     */
    public static inline function process(string: String, data: KeyboardEventData, allowedCharCodes: Vector<Bool>, callback: String -> Void): Void
    {
        if (data.state == KeyState.Up)
        {
            var keyCode: Int = data.keyCode;
            var isUpper: Bool = data.shiftKeyPressed != data.capsKeyPressed;

            // apply shift modifications to the keycode to make it properly lower- or upper-case
            keyCode = modifyKey(isUpper, keyCode);

            if (keyIsBackspace(keyCode))
            {
                string = string.substr(0, string.length - 1);
            }
            else if (keyCode < allowedCharCodes.length && allowedCharCodes[keyCode])
            {
                string = string + String.fromCharCode(keyCode);
            }

            if (callback != null)
            {
                callback(string);
            }
        }
    }

    private static inline function keyIsBackspace(keyCode: Int): Bool
    {
        return keyCode == 8;
    }

    private static inline function modifyKey(isUpper: Bool, keyCode: Int): Int
    {
        if ((keyCode >= 65 && keyCode <= 90) && !isUpper)
        {
            // 65 is 'A', 97 is 'a'
            return keyCode + 32;
        }

        return keyCode;
    }
}
