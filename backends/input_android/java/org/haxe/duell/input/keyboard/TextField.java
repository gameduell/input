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

import android.text.Editable;
import android.text.TextWatcher;
import org.haxe.duell.DuellActivity;
import org.haxe.duell.hxjni.HaxeObject;
import org.haxe.duell.input.DuellInputActivityExtension;
import org.haxe.duell.input.event.CentralHaxeDispatcher;

import java.util.BitSet;
import java.util.regex.Pattern;

import android.util.Log;

public class TextField implements KeyboardViewDelegate, TextWatcher
{
    private final CentralHaxeDispatcher dispatcher;

    private KeyboardView keyboardView;

    private String text;
    private BitSet validCharacters;

    private boolean eatEvent;

    public static TextField init(HaxeObject hxObject)
    {
        return new TextField(hxObject);
    }

    private TextField(HaxeObject hxObject)
    {
        dispatcher = new CentralHaxeDispatcher(hxObject);
        text = "";
        validCharacters = new BitSet(256);

        final Thread currentThread = Thread.currentThread();

        DuellActivity.getInstance().runOnUiThread(new Runnable()
        {
            @Override
            public void run()
            {
                keyboardView = new KeyboardView(DuellActivity.getInstance());
                keyboardView.setDelegate(TextField.this);
                DuellInputActivityExtension.extension.get().setManagedKeyboardView(keyboardView);

                keyboardView.addTextChangedListener(TextField.this);

                currentThread.interrupt();
            }
        });

        long timestamp = System.currentTimeMillis();

        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            Log.d("duell", "TextField ready after " + (System.currentTimeMillis() - timestamp) + " ms");
        }
    }

    public void setAllowedCharCodes(boolean[] charCodes)
    {
        if (charCodes.length > validCharacters.length())
        {
            // expand the size if needed
            validCharacters = new BitSet(charCodes.length);
        }

        // reset all flags to false
        validCharacters.clear();

        for (int i = 0; i < charCodes.length; i++)
        {
            validCharacters.set(i, charCodes[i]);
        }
    }

    public boolean show()
    {
        return keyboardView.show();
    }

    public boolean hide()
    {
        return keyboardView.hide();
    }

    @Override
    public void willShow()
    {
        dispatcher.dispatchEvent(CentralHaxeDispatcher.INPUT_STARTED_EVENT, null);
    }

    @Override
    public void willHide()
    {
        dispatcher.dispatchEvent(CentralHaxeDispatcher.INPUT_ENDED_EVENT, null);

        final String string = keyboardView.getText().toString();
        // manually call this to reset the string from the edittext, ensure nothing was broken by the keyboard dismissing
        onTextChanged(string, 0, 0, string.length());
    }

    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after)
    {
    }

    @Override
    public void onTextChanged(final CharSequence s, int start, int before, int count)
    {
        // event was flagged as eaten, don't execute logic
        if (eatEvent)
        {
            return;
        }

        String string = text;

        if (string.length() > s.length())
        {
            // keyboardViewDidDeleteBackward
            string = s.toString();
        }
        else if (string.length() <= s.length())
        {
            // keyboardViewDidInsertText
            string = s.toString();
            String processedText = string;
            for (int i = 0; i < string.length(); i++)
            {
                if (!validCharacters.get(string.charAt(i)))
                {
                    // force event to be eaten, as this method will execute again
                    eatEvent = true;
                    processedText = processedText.replaceAll(Pattern.quote("" + string.charAt(i)), "");
                }

                if (eatEvent)
                {
                    // set the text back and update the keyboard view
                    string = processedText;

                    // ensure this is done in the ui thread
                    DuellActivity.getInstance().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            keyboardView.setText(s);

                            // point the cursor to the end, its position gets messed up after replacing
                            keyboardView.setSelection(Math.max(0, s.length() - 1));
                        }
                    });
                }
            }
        }
        text = string;
        dispatcher.dispatchEvent(CentralHaxeDispatcher.TEXT_CHANGED_EVENT, text);
    }

    @Override
    public void afterTextChanged(Editable s)
    {
        if (eatEvent)
        {
            eatEvent = false;
        }
    }

    public void setText(final String s)
    {
        text = s;
        DuellActivity.getInstance().runOnUiThread(new Runnable()
        {
            @Override
            public void run()
            {
                eatEvent = true;
                keyboardView.setText(s);
                keyboardView.setSelection(s.length());
            }
        });
    }
}
