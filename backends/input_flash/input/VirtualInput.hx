/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package input;

import input.util.KeyboardInputProcessor;
import haxe.ds.Vector;
import msignal.Signal;

using input.util.VectorUtils;

/**
    @author jxav
 */
class VirtualInput
{
    public var onInputStarted(default, null): Signal0;
    public var onInputEnded(default, null): Signal0;
    public var onTextChanged(default, null): Signal1<String>;

    public var text(default, set): String;

    public var allowedCharCodes(null, set): Vector<Bool>;

    private var inputAllowed: Bool;

    private function new(charCodes: Vector<Bool>)
    {
        onInputStarted = new Signal0();
        onInputEnded = new Signal0();
        onTextChanged = new Signal1();

        text = "";
        allowedCharCodes = charCodes;
        inputAllowed = false;

        KeyboardManager.instance().getMainKeyboard().onKeyboardEvent.add(function(data: KeyboardEventData): Void
        {
            if (inputAllowed)
            {
                KeyboardInputProcessor.process(text, data, allowedCharCodes, set_text);
            }
        });
    }

    private function show(): Void
    {
        inputAllowed = true;

        onInputStarted.dispatch();
    }

    private function hide(): Void
    {
        inputAllowed = false;

        onInputEnded.dispatch();
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

    private function set_allowedCharCodes(value: Vector<Bool>): Vector<Bool>
    {
        allowedCharCodes = value.copy();

        return value;
    }
}