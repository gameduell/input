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

import input.util.CharSet;

@:access(input.VirtualInput)
class VirtualInputManager
{
    private static var mgrInstance: VirtualInputManager;

    private var input: VirtualInput;

    private function new()
    {
        // initializes the input with the default english charcode set
        input = new VirtualInput(CharSet.englishCharCodeSet());
    }

    /**
        Accesses the singleton instance of this virtual input manager.
     */
    public static inline function instance(): VirtualInputManager
    {
        return mgrInstance;
    }

    /**
        Initializes the virtual input manager. Clients shouldn't care about this step.
     */
    public static function initialize(finishedCallback: Void -> Void): Void
    {
        mgrInstance = new VirtualInputManager();

        if (finishedCallback != null)
        {
            finishedCallback();
        }
    }

    /**
        Retrieves the main virtual input instance.
     */
    public function getVirtualInput(): VirtualInput
    {
        return input;
    }

    /**
        Shows / allows the virtual input to start. Returns `true` if the input will show asynchronously or `false` if it
        will be shown synchronously.
     */
    public function show(): Bool
    {
        return input.show();
    }

    /**
        Hides / forbids the virtual input from taking input. Returns `true` if the input will hide asynchronously or
        `false` if it will be hidden synchronously.
     */
    public function hide(): Bool
    {
        return input.hide();
    }
}
