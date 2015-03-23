/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package input;

/**   
   @author jxav
 */
extern class VirtualInputManager
{
    public static function instance(): VirtualInputManager;

    public function getVirtualKeyboard(): VirtualInput;

    public static function initialize(finishedCallback: Void -> Void): Void;

    public function show(): Void;

    public function hide(): Void;
}
