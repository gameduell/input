package org.haxe.duell.input;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import org.haxe.duell.DuellActivity;
import org.haxe.duell.Extension;

import java.lang.ref.WeakReference;

public class DuellInputActivityExtension extends Extension
{

    private static WeakReference<DuellInputActivityExtension> extension = new WeakReference<DuellInputActivityExtension>(null);

    private WeakReference<View> currentView = new WeakReference<View>(null);

    public static void initialize()
    {
        final View currentView = DuellActivity.getInstance().mainView.get();

        if (currentView == null)
        {
            throw new IllegalStateException("There is no view currently in focus. Please initialize the input library " +
                    "after a view as been created. E.g. initializing the opengl library.");
        }

        final View prevView = extension.get().currentView.get();

        if (prevView != null)
        {
            prevView.setOnTouchListener(null);
        }

        currentView.setOnTouchListener(new DuellInputTouchListener());
        extension.get().currentView = new WeakReference<View>(currentView);
    }

    /**
     * Called when an activity you launched exits, giving you the requestCode you started it with, the resultCode it
     * returned, and any additional data from it.
     */
    public boolean onActivityResult(int requestCode, int resultCode, Intent data)
    {

        return true;

    }


    /**
     * Called when the activity is starting.
     */
    public void onCreate(Bundle savedInstanceState)
    {

        extension = new WeakReference<DuellInputActivityExtension>(this);

    }


    /**
     * Perform any final cleanup before an activity is destroyed.
     */
    public void onDestroy()
    {


    }


    /**
     * Called when the overall system is running low on memory, and actively running processes should trim their memory
     * usage. This is a backwards compatibility method as it is called at the same time as
     * onTrimMemory(TRIM_MEMORY_COMPLETE).
     */
    public void onLowMemory()
    {


    }


    /**
     * Called when the a new Intent is received
     */
    public void onNewIntent(Intent intent)
    {


    }


    /**
     * Called as part of the activity lifecycle when an activity is going into the background, but has not (yet) been
     * killed.
     */
    public void onPause()
    {


    }


    /**
     * Called after {@link #onStop} when the current activity is being re-displayed to the user (the user has navigated
     * back to it).
     */
    public void onRestart()
    {


    }


    /**
     * Called after {@link #onRestart}, or {@link #onPause}, for your activity to start interacting with the user.
     */
    public void onResume()
    {


    }


    /**
     * Called after {@link #onCreate} &mdash; or after {@link #onRestart} when the activity had been stopped, but is now
     * again being displayed to the user.
     */
    public void onStart()
    {


    }


    /**
     * Called when the activity is no longer visible to the user, because another activity has been resumed and is
     * covering this one.
     */
    public void onStop()
    {


    }


    /**
     * Called when the operating system has determined that it is a good time for a process to trim unneeded memory from
     * its process.
     * <p/>
     * See http://developer.android.com/reference/android/content/ComponentCallbacks2.html for the level explanation.
     */
    public void onTrimMemory(int level)
    {


    }


}