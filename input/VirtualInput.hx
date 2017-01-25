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

import msignal.Signal;

/**
	Interface of the Virtual Input.
 */
extern class VirtualInput
{
    private function new(chars: String);
    /**
        Callback fired when the input is allowed to be started.
     */
    public var onInputStarted(default, null): Signal0;
    /**
        Callback fired when the input has ended.
     */
    public var onInputEnded(default, null): Signal0;

    /**
        Callback fired when there was a change in the text. Contains the changed string as an argument.
     */
    public var onTextChanged(default, null): Signal1<String>;

    /**
        Current string on the input buffer. Can be reset by clients.
     */
    public var text(default, set): String;

    /**
        Sets the allowed char codes in this virtual input which should be handled natively.
     */
    public function setAllowedChars(allowedString: String): Void;

    private function show(): Bool;
    private function hide(): Bool;
    private function set_text(string: String): String;
}
