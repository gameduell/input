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

import haxe.ds.Vector;
import hxjni.JNI;
import msignal.Signal;
@:keep
class VirtualInput
{
    private static var initNative = JNI.createStaticMethod("org/haxe/duell/input/keyboard/TextField",
    "init", "(Lorg/haxe/duell/hxjni/HaxeObject;)Lorg/haxe/duell/input/keyboard/TextField;");
    private static var showNative = JNI.createMemberMethod("org/haxe/duell/input/keyboard/TextField", "show", "()Z");
    private static var hideNative = JNI.createMemberMethod("org/haxe/duell/input/keyboard/TextField", "hide", "()Z");
    private static var setTextNative = JNI.createMemberMethod("org/haxe/duell/input/keyboard/TextField",
    "setText", "(Ljava/lang/String;)V");
    private static var setAllowedCharCodesNative = JNI.createMemberMethod("org/haxe/duell/input/keyboard/TextField",
    "setAllowedCharCodes", "([Z)V");

    private var javaObj: Dynamic;

    public var onInputStarted(default, null): Signal0;
    public var onInputEnded(default, null): Signal0;
    public var onTextChanged(default, null): Signal1<String>;

    public var text(default, set): String;

    public var allowedCharCodes(null, set): Vector<Bool>;

    private function new(charCodes: Vector<Bool>)
    {
        onInputStarted = new Signal0();
        onInputEnded = new Signal0();
        onTextChanged = new Signal1();

        javaObj = initNative(this);

        text = "";
        allowedCharCodes = charCodes;
    }

    private function show(): Bool
    {
        return showNative(javaObj);
    }

    private function hide(): Bool
    {
        return hideNative(javaObj);
    }

    private function onInputStartedCallback()
    {
        onInputStarted.dispatch();
    }

    private function onInputEndedCallback()
    {
        onInputEnded.dispatch();
    }
    private function onTextChangedCallback(data: Dynamic)
    {
        /// could just call the setter, but we want to avoid the setTextNative
        if (text != data)
        {
            text = data;
            onTextChanged.dispatch(data);
        }
    }

    private function set_text(value: String): String
    {
        if (text != value)
        {
            text = value;
            setTextNative(javaObj, value);
            onTextChanged.dispatch(value);
        }

        return value;
    }

    private function set_allowedCharCodes(value: Vector<Bool>): Vector<Bool>
    {
        setAllowedCharCodesNative(javaObj, value);

        return value;
    }
}
