package org.haxe.duell.input;

class DuellInputNativeInterface {

	public static native void startTouchInfoBatch(int count);

	public static native void touchInfo(int id, float x, float y, int state);

}
