/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package input;

import input.util.CharSet;

/**
    @author jxav
 */
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
        Shows / allows the virtual input to start.
     */
    public function show(): Void
    {
        input.show();
    }

    /**
        Hides / forbids the virtual input from taking input.
     */
    public function hide(): Void
    {
        input.hide();
    }
}
