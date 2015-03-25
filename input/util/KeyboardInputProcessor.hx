/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package input.util;

import haxe.ds.Vector;
import input.KeyboardEventData;

/**   
   @author jxav
 */
@:final class KeyboardInputProcessor
{
    /**
        Processes the string input on `string` using the keyboard event data encoded in `data`, restricting the input
        according to the flags specified in `allowedCharCodes`.

        Returns the final input to `callback`.
     */
    public static inline function process(string: String, data: KeyboardEventData, allowedCharCodes: Vector<Bool>, callback: String -> Void): Void
    {
        if (data.state == KeyState.Up)
        {
            var keyCode: Int = data.keyCode;
            var shiftPressed: Bool = data.shiftKeyPressed;

            keyCode = modifyKey(shiftPressed, keyCode);

            if (keyIsBackspace(keyCode))
            {
                string = string.substr(0, string.length - 1);
            }
            else if (allowedCharCodes[keyCode])
            {
                string = string + String.fromCharCode(keyCode);
            }

            if (callback != null)
            {
                callback(string);
            }
        }
    }

    private static inline function keyIsBackspace(keyCode: Int): Bool
    {
        return keyCode == 8;
    }

    private static inline function modifyKey(shiftPressed: Bool, keyCode: Int): Int
    {
        if ((keyCode >= 65 && keyCode <= 90) && !shiftPressed)
        {
            // 65 is 'A', 97 is 'a'
            return keyCode + 32;
        }

        return keyCode;
    }
}
