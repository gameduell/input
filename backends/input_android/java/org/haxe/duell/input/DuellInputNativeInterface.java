/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package org.haxe.duell.input;

class DuellInputNativeInterface
{

    public static native void startTouchInfoBatch(int count);

    public static native void touchInfo(int id, float x, float y, int state);

}
