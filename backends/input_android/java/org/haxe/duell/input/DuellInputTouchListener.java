package org.haxe.duell.input;

import java.lang.ref.WeakReference;
import java.util.LinkedList;
import java.util.ListIterator;

import android.view.MotionEvent;
import android.view.View;
import android.util.Log;
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

			///0 began, 1 moved, 2 stationary, 3 ended, 4 cancelled
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
						touch.cancel();
					}
				} else {
					for (int i = 0; i < ev.getPointerCount(); ++i) {

						int stateForThisTouch = 1;
						if (i == indexOfAction) {
							stateForThisTouch = state;
						}

						final int id = ev.getPointerId(i) + (int)ev.getDownTime();

						DuellInputTouch touchToBeUpdated = null;
						for (DuellInputTouch touch : touches) {
							if (touch.id == id) {
								touchToBeUpdated = touch;
								break;
							}
						}

						if (touchToBeUpdated == null) {
							if (stateForThisTouch != 0)
							{
								continue;/// we don't create a touch when the state is not began
							}

							touchToBeUpdated = DuellInputTouch.getPooledTouch();
							touchToBeUpdated.id = id;
							touches.add(touchToBeUpdated);
						}


						touchToBeUpdated.pushData(ev.getX(i), ev.getY(i), stateForThisTouch);
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

			boolean pendingFound = true;

			while (pendingFound) {
				pendingFound = false;

				DuellInputNativeInterface.startTouchInfoBatch(touches.size());
				ListIterator<DuellInputTouch> itr = touches.listIterator();

				while (itr.hasNext()) {

					final DuellInputTouch touch = itr.next();

					touch.uploadData();

					if (touch.hasPendingData())
					{
						pendingFound = true;;
					}

					if (touch.isFinished())
					{
						itr.remove();
						DuellInputTouch.recycle(touch);
					}
				}
			}
			pendingQueueProcessing = false;
		}
	}


}