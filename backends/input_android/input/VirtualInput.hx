/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package input;

import haxe.ds.Vector;
import hxjni.JNI;
import msignal.Signal;

/**
    @author jxav
 */
class VirtualInput
{
    private static var initNative = JNI.createStaticMethod("org/haxe/duell/input/keyboard/TextField",
    "init", "(Lorg/haxe/duell/hxjni/HaxeObject;)Lorg/haxe/duell/input/keyboard/TextField;");
    private static var showNative = JNI.createMemberMethod("org/haxe/duell/input/keyboard/TextField", "show", "()V");
    private static var hideNative = JNI.createMemberMethod("org/haxe/duell/input/keyboard/TextField", "hide", "()V");
    private static var setTextNative = JNI.createMemberMethod("org/haxe/duell/input/keyboard/TextField",
    "setText", "(Ljava/lang/String;)V");
    private static var setAllowedCharCodesNative = JNI.createMemberMethod("org/haxe/duell/input/keyboard/TextField",
    "setAllowedCharCodes", "([Z)V");

    private var javaObj: Dynamic;

    public var onInputStarted(default, null): Signal0;
    public var onInputEnded(default, null): Signal0;
    public var onTextChanged(default, null): Signal1<String>;

    public var text(default, set): String;

    public var allowedCharCodes(never, set): Vector<Bool>;

    private function new(charCodes: Vector<Bool>)
    {
        onInputStarted = new Signal0();
        onInputEnded = new Signal0();
        onTextChanged = new Signal1();

        javaObj = initNative(this);

        text = "";
        allowedCharCodes = charCodes;
    }

    private function show(): Void
    {
        showNative(javaObj);
    }

    private function hide(): Void
    {
        hideNative(javaObj);
    }

    public function onInputStartedCallback()
    {
        onInputStarted.dispatch();
    }

    public function onInputEndedCallback()
    {
        onInputEnded.dispatch();
    }

    public function onTextChangedCallback(data: Dynamic)
    {
        text = data;
    }

    private function set_text(value: String): String
    {
        if (text != value)
        {
            setTextNative(javaObj, value);

            text = value;

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