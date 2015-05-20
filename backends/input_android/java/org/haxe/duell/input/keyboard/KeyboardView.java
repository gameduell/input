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

package org.haxe.duell.input.keyboard;

import android.annotation.TargetApi;
import android.content.Context;
import android.os.Build;
import android.view.KeyEvent;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.TextView;
import org.haxe.duell.DuellActivity;

import java.lang.ref.WeakReference;

@TargetApi(Build.VERSION_CODES.HONEYCOMB)
public class KeyboardView extends EditText
{

    private WeakReference<KeyboardViewDelegate> delegate;
    private boolean isShowing;

    public KeyboardView(final Context context)
    {
        super(context);

        delegate = new WeakReference<KeyboardViewDelegate>(null);

        setLayoutParams(new ViewGroup.LayoutParams(1, 1));
        setAlpha(0.0f);
        setEnabled(true);
        setFocusable(true);
        setFocusableInTouchMode(true);
        setClickable(true);

        setSingleLine();
        setImeOptions(EditorInfo.IME_ACTION_DONE);
        setOnEditorActionListener(new OnEditorActionListener()
        {
            @Override
            public boolean onEditorAction(final TextView _v, final int _actionId, final KeyEvent _event)
            {
                if (_actionId == EditorInfo.IME_ACTION_DONE)
                {
                    isShowing = false;

                    KeyboardViewDelegate viewDelegate = delegate.get();
                    if (viewDelegate != null)
                    {
                        viewDelegate.willHide();
                    }
                }
                return false;
            }
        });
    }

    @Override
    public boolean onKeyPreIme(final int keyCode, final KeyEvent event)
    {
        if (event.getAction() == KeyEvent.ACTION_UP && keyCode == KeyEvent.KEYCODE_BACK)
        {
            isShowing = false;

            KeyboardViewDelegate viewDelegate = delegate.get();
            if (viewDelegate != null)
            {
                viewDelegate.willHide();
            }
        }

        return super.onKeyPreIme(keyCode, event);
    }

    public boolean show()
    {
        // show only if it's not showing
        if (!isShowing)
        {
            // force toggle keyboard
            InputMethodManager imm =
                    (InputMethodManager) DuellActivity.getInstance().getSystemService(Context.INPUT_METHOD_SERVICE);

            if (imm != null)
            {
                // requesting focus - UI thread
                DuellActivity.getInstance().runOnUiThread(new Runnable()
                {
                    @Override
                    public void run()
                    {
                        requestFocus();
                    }
                });

                imm.toggleSoftInput(InputMethodManager.SHOW_FORCED, 0);
                isShowing = true;

                KeyboardViewDelegate viewDelegate = delegate.get();

                if (viewDelegate != null)
                {
                    viewDelegate.willShow();
                    return true;
                }
            }
        }

        return false;
    }

    public boolean hide()
    {
        // hide only if it is showing
        if (isShowing)
        {
            // force dismiss keyboard
            InputMethodManager imm =
                    (InputMethodManager) DuellActivity.getInstance().getSystemService(Context.INPUT_METHOD_SERVICE);

            if (imm != null)
            {
                imm.toggleSoftInput(InputMethodManager.SHOW_FORCED, 0);
                isShowing = false;

                KeyboardViewDelegate viewDelegate = delegate.get();

                if (viewDelegate != null)
                {
                    viewDelegate.willHide();
                    return true;
                }
            }
        }

        return false;
    }

    void setDelegate(KeyboardViewDelegate delegate)
    {
        this.delegate = new WeakReference<KeyboardViewDelegate>(delegate);
    }
}
