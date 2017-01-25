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

import js.html.KeyboardEvent;
import input.KeyboardEventData;

@:final class KeyboardInputProcessor
{
    /**
        Processes the string input on `test` using the keyboard event data encoded in `data`, restricting the input
        according to the flags specified in `allowedCharCodes`.

        Returns the final input to `callback`.
     */
    public static inline function process(text: String, data: KeyboardEventData, allowedCharCodes: Array<Bool>, callback: String -> Void): Void
    {
        var isUpdated: Bool = false;

        if (data.state == KeyState.Down)
        {
            if (data.keyCode == KeyboardEvent.DOM_VK_BACK_SPACE)
            {
                text = text.substr(0, text.length - 1);
                isUpdated = true;
            }

        }

        if (data.state == KeyState.Press)
        {
            if (data.charCode == KeyboardEvent.DOM_VK_BACK_SPACE)
            {
                text = text.substr(0, text.length - 1);
                isUpdated = true;
            }
            else if (data.charCode < allowedCharCodes.length && allowedCharCodes[data.charCode])
            {
                text = text + String.fromCharCode(data.charCode);
                isUpdated = true;
            }
        }

        if (isUpdated && callback != null)
        {
            callback(text);
        }
    }

}
