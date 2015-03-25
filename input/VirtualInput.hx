/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package input;

import haxe.ds.Vector;
import msignal.Signal;

/**
    @author jxav
 */
extern class VirtualInput
{
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
        The allowed char codes in this virtual input. Must be a 256-length `Vector`.
     */
    public var allowedCharCodes(null, default): Vector<Bool>;
}