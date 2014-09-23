package org.haxe.duell.input;

import java.lang.ref.WeakReference;
import java.util.LinkedList;
import java.util.ListIterator;

import android.view.MotionEvent;
import android.view.View;
import org.haxe.duell.DuellActivity;
import org.haxe.duell.input.DuellInputTouch;

class DuellInputTouchListener implements Runnable, View.OnTouchListener {
	private final WeakReference<DuellActivity> activity = new WeakReference(DuellActivity.getInstance());
	private final LinkedList<DuellInputTouch> touches = new LinkedList();
	private volatile boolean pendingQueueProcessing = false;

	@Override
	public boolean onTouch(View v, MotionEvent ev) {
			int state = 0;
			final int action = ev.getAction();
			final int indexOfAction = ev.getActionIndex();
			boolean cancel = false;

			///0 began, 1 moved, 2 stationary, 3 ended
			switch (action & MotionEvent.ACTION_MASK) {
				case MotionEvent.ACTION_DOWN:
					state = 0;
					break;
				case MotionEvent.ACTION_POINTER_DOWN:
					state = 0;
					break;
				case MotionEvent.ACTION_MOVE:
					state = 1;
					break;
				case MotionEvent.ACTION_UP:
					state = 3;
					break;
				case MotionEvent.ACTION_POINTER_UP:
					state = 3;
					break;
				case MotionEvent.ACTION_CANCEL:
					cancel = true;
					break;
			}

			synchronized (touches) {
				if (cancel) { /// cancel everything
					for (DuellInputTouch touch : touches) {
						touch.state = 3;
					}
				} else {
					for (int i = 0; i < ev.getPointerCount(); ++i) {
						final int id = ev.getPointerId(i);

						DuellInputTouch touchToBeUpdated = null;
						for (DuellInputTouch touch : touches) {
							if (touch.id == id) {
								touchToBeUpdated = touch;
								break;
							}
						}
						if (touchToBeUpdated == null) {
							touchToBeUpdated = DuellInputTouch.getPooledTouch();
							touchToBeUpdated.id = id;
							touches.add(touchToBeUpdated);
						}

						touchToBeUpdated.x = ev.getX(i);
						touchToBeUpdated.y = ev.getY(i);
						if (i == indexOfAction) {
							touchToBeUpdated.state = state;
						} else {
							touchToBeUpdated.state = 1;
						}
					}
				}
			}

			if (!pendingQueueProcessing) {
				pendingQueueProcessing = true;
				DuellActivity activityLocal = activity.get();
				if(activityLocal != null) {
					activityLocal.queueOnHaxeThread(this);
				}
			}
		return true;
	}

	@Override
	public void run() {

		synchronized (touches) {
			DuellInputNativeInterface.startTouchInfoBatch(touches.size());
			ListIterator<DuellInputTouch> itr = touches.listIterator();
			while (itr.hasNext()) {
				final DuellInputTouch touch = itr.next();

				DuellInputNativeInterface.touchInfo(touch.id, touch.x, touch.y, touch.state);

				if (touch.state == 3) {
					itr.remove();
					DuellInputTouch.recycle(touch);
				}
			}
			pendingQueueProcessing = false;
		}
	}


}