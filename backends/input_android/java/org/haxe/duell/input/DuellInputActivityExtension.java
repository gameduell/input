/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package org.haxe.duell.input;

import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import org.haxe.duell.DuellActivity;
import org.haxe.duell.Extension;
import org.haxe.duell.input.keyboard.KeyboardView;
import org.haxe.duell.input.keyboard.ManagedKeyboardViewer;

import java.lang.ref.WeakReference;

public class DuellInputActivityExtension extends Extension implements ManagedKeyboardViewer
{

    public static WeakReference<DuellInputActivityExtension> extension = new WeakReference<DuellInputActivityExtension>(null);

    private WeakReference<View> currentView = new WeakReference<View>(null);

    private KeyboardView managedKeyboardView;
    private KeyboardView defaultKeyboardView;

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

        // init keyboard handling
        extension.get().initializeKeyboardHandling();
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

    //
    // Keyboard handling
    //

    private void initializeKeyboardHandling()
    {
        // use a default keyboard so that no NPE is thrown
        defaultKeyboardView = new KeyboardView(DuellActivity.getInstance());
        managedKeyboardView = defaultKeyboardView;
    }

    @Override
    public void setManagedKeyboardView(final KeyboardView _keyboardView)
    {
        final ViewGroup parent = DuellActivity.getInstance().parent;

        DuellActivity.getInstance().runOnUiThread(new Runnable()
        {
            @Override
            public void run()
            {
                parent.removeView(managedKeyboardView);

                if (_keyboardView != null)
                {
                    managedKeyboardView = _keyboardView;
                    parent.addView(managedKeyboardView);
                }
                else
                {
                    managedKeyboardView = defaultKeyboardView;
                }

                managedKeyboardView.setText("");
            }
        });
    }

    @Override
    public void onKeyDown(int keyCode, KeyEvent event)
    {
        if (managedKeyboardView != null)
        {
            managedKeyboardView.onKeyDown(keyCode, event);
        }
    }

    @Override
    public void onKeyUp(int keyCode, KeyEvent event)
    {
        if (managedKeyboardView != null)
        {
            managedKeyboardView.onKeyUp(keyCode, event);
        }
    }
}
