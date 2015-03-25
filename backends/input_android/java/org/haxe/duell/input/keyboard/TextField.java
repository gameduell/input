/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
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

/**
 * @author jxav
 */
public class TextField implements KeyboardViewDelegate, TextWatcher
{
    private final CentralHaxeDispatcher dispatcher;
    private final KeyboardView keyboardView;

    private String text;

    private final BitSet validCharacters;

    private boolean eatEvent;

    public static TextField init(HaxeObject hxObject)
    {
        return new TextField(hxObject);
    }

    private TextField(HaxeObject hxObject)
    {
        dispatcher = new CentralHaxeDispatcher(hxObject);

        keyboardView = new KeyboardView(DuellActivity.getInstance());
        keyboardView.setDelegate(this);
        DuellInputActivityExtension.extension.get().setManagedKeyboardView(keyboardView);

        keyboardView.addTextChangedListener(this);

        text = "";
        validCharacters = new BitSet(256);
    }

    public void setAllowedCharCodes(boolean[] charCodes)
    {
        for (int i = 0; i < 256; i++)
        {
            validCharacters.set(i, charCodes[i]);
        }
    }

    public void show()
    {
        keyboardView.show();
    }

    public void hide()
    {
        keyboardView.hide();
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
    public void onTextChanged(CharSequence s, int start, int before, int count)
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
        else if (string.length() < s.length())
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

                    keyboardView.setText(s);

                    // point the cursor to the end, its position gets messed up after replacing
                    keyboardView.setSelection(Math.max(0, s.length() - 1));
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

    public void setString(final String s)
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
