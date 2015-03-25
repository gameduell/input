/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package input;

import cpp.Lib;
import haxe.ds.Vector;
import msignal.Signal;

/**
    @author jxav
 */
class VirtualInput
{
    private static var initializeNative = Lib.load("input_ios", "input_ios_text_create_textfieldwrapper", 2);
    private static var showKeyboardNative = Lib.load("input_ios", "input_ios_text_show_keyboard", 1);
    private static var hideKeyboardNative = Lib.load("input_ios", "input_ios_text_hide_keyboard", 1);
    private static var setAllowedCharCodesNative = Lib.load("input_ios", "input_ios_text_set_allowed_char_codes", 2);
    private static var setStringNative = Lib.load("input_ios", "input_ios_text_set_string", 2);

    public var onInputStarted(default, null): Signal0;
    public var onInputEnded(default, null): Signal0;
    public var onTextChanged(default, null): Signal1<String>;

    public var string(default, set): String;

    public var allowedCharCodes(never, set): Vector<Bool>;

    private var obj: Dynamic;

    private function new(charCodes: Vector<Bool>)
    {
        onInputStarted = new Signal0();
        onInputEnded = new Signal0();
        onTextChanged = new Signal1();

        obj = initializeNative(onInputEnded.dispatch, set_string);

        string = "";
        allowedCharCodes = charCodes;
    }

    private function show(): Void
    {
        showKeyboardNative(obj);

        onInputStarted.dispatch();
    }

    private function hide(): Void
    {
        hideKeyboardNative(obj);
    }

    private function set_string(value: String): String
    {
        if (string != value)
        {
            setStringNative(obj, value);

            string = value;

            onTextChanged.dispatch(value);
        }

        return value;
    }

    private function set_allowedCharCodes(value: Vector<Bool>): Vector<Bool>
    {
        if (value.length != 256)
        {
            throw 'Invalid vector length for allowed char codes ${value.length}';
        }

        setAllowedCharCodesNative(obj, value);

        return value;
    }
}