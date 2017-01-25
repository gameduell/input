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

import input.util.KeyboardInputProcessor;
import msignal.Signal;

using input.util.VectorUtils;

class VirtualInput
{
    public var onInputStarted(default, null): Signal0;
    public var onInputEnded(default, null): Signal0;
    public var onTextChanged(default, null): Signal1<String>;

    public var text(default, set): String;
    public var allowedCharCodes (default, null): Array<Bool>;

    private var inputAllowed: Bool;

    private function new(chars: String)
    {
        onInputStarted = new Signal0();
        onInputEnded = new Signal0();
        onTextChanged = new Signal1();

        text = "";
        setAllowedChars(chars);
        inputAllowed = false;

        KeyboardManager.instance().getMainKeyboard().onKeyboardEvent.add(function(data: KeyboardEventData): Void
        {
            if (inputAllowed)
            {
                KeyboardInputProcessor.process(text, data, allowedCharCodes, set_text);
            }
        });
    }

    private function show(): Bool
    {
        inputAllowed = true;

        onInputStarted.dispatch();

        return false;
    }

    private function hide(): Bool
    {
        inputAllowed = false;

        onInputEnded.dispatch();

        return false;
    }

    private function set_text(value: String): String
    {
        if (value != text)
        {
            text = value;

            onTextChanged.dispatch(value);
        }

        return value;
    }

    public function setAllowedChars(allowedString: String): Void
    {
        allowedCharCodes = [];

        for (i in 0 ... allowedString.length)
        {
            allowedCharCodes[allowedString.charCodeAt(i)] = true;
        }
    }
}
