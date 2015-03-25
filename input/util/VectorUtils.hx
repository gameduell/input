/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package input.util;

import haxe.ds.Vector;

/**
    @author jxav
 */
@:final class VectorUtils
{
    /**
        Returns a shallow copy of `src`.
     */
    @:generic
    public static function copy<T>(src: Vector<T>): Vector<T>
    {
        var len: Int = src.length;

        var dst: Vector<T> = new Vector(len);
        Vector.blit(src, 0, dst, 0, len);

        return dst;
    }
}
