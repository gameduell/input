/*
 * Copyright (c) 2003-2015, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
import android.view.WindowManager;

import java.lang.ref.WeakReference;

import android.util.Log;

public class DuellInputActivityExtension extends Extension implements ManagedKeyboardViewer
{

    public static WeakReference<DuellInputActivityExtension> extension = new WeakReference<DuellInputActivityExtension>(null);

    private static Runnable extensionCompletion = null;

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

        extensionCompletion = new Runnable()
        {
            @Override
            public void run()
            {
                final View prevView = extension.get().currentView.get();

                if (prevView != null)
                {
                    prevView.setOnTouchListener(null);
                }

                currentView.setOnTouchListener(new DuellInputTouchListener());
                extension.get().currentView = new WeakReference<View>(currentView);
            }
        };

        // initialize was probably created before onCreate, so we wait for it to be called after onCreate
        if (extension.get() != null)
        {
            extensionCompletion.run();
            extensionCompletion = null;
        }
    }

    /**
     * Called when an activity you launched exits, giving you the requestCode you started it with, the resultCode it
     * returned, and any additional data from it.
     */
    public boolean onActivityResult(int requestCode, int resultCode, Intent data)
    {

        return false;

    }

    /**
     * Called when the activity is starting.
     */
    public void onCreate(Bundle savedInstanceState)
    {
        extension = new WeakReference<DuellInputActivityExtension>(this);

        DuellActivity.getInstance().getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);

        initializeKeyboardHandling();

        // this is by the way, as well as the extension, a bad exploit of static variables
        if (extensionCompletion != null)
        {
            extensionCompletion.run();
            extensionCompletion = null;
        }
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
        final DuellActivity duellActivity = DuellActivity.getInstance();

        if(duellActivity != null)
        {
            // use a default keyboard so that no NPE is thrown
            defaultKeyboardView = new KeyboardView(duellActivity);
            managedKeyboardView = defaultKeyboardView;
        }
    }

    @Override
    public void setManagedKeyboardView(final KeyboardView _keyboardView)
    {

        final ViewGroup parent = DuellActivity.getInstance().parent;

        final Thread currentThread = Thread.currentThread();

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

                currentThread.interrupt();
            }
        });

        long timestamp = System.currentTimeMillis();

        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            Log.d("duell", "managedKeyboardView ready after " + (System.currentTimeMillis() - timestamp) + " ms");
        }
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
