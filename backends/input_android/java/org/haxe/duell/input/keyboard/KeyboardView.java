/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
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

/**
 * @author jxav
 */
@TargetApi(Build.VERSION_CODES.HONEYCOMB)
public class KeyboardView extends EditText {

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

    public void show()
    {
        // don't show if it's showing
        if (isShowing)
        {
            return;
        }

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
            }
        }
    }

    public void hide()
    {
        // don't hide if it's not showing
        if (!isShowing)
        {
            return;
        }

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
            }
        }
    }

    void setDelegate(KeyboardViewDelegate delegate)
    {
        this.delegate = new WeakReference<KeyboardViewDelegate>(delegate);
    }
}
