/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package input.util;

import haxe.ds.Vector;

/**   
    @author jxav
 */
@:final class CharSet
{
    /**
        Returns the english letters char code set, with [A-Za-z] and spaces enabled.
     */
    public static function englishCharCodeSet(): Vector<Bool>
    {
        var set: Vector<Bool> = new Vector(256);

        for (i in 0...256)
        {
            set[i] = false;
        }

        // space
        set[32] = true;

        // uppercase chars
        for (i in 65...91)
        {
            set[i] = true;
        }

        // lowercase chars
        for (i in 97...123)
        {
            set[i] = true;
        }

        return set;
    }
}
