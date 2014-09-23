package org.haxe.duell.input;

import java.util.ArrayDeque;
import java.util.Deque;

class DuellInputTouch {
	public int id;
	public float x;
	public float y;
	public int state;

	private static final Deque<DuellInputTouch> poolAvailable = new ArrayDeque();
	public static DuellInputTouch getPooledTouch() {
		DuellInputTouch po;
		if (!poolAvailable.isEmpty()) {
			po = poolAvailable.removeFirst();
		} else {
			po = new DuellInputTouch();
		}
		return po;
	}

	public static void recycle(DuellInputTouch po) {
		poolAvailable.addLast(po);
	}
}