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

package org.haxe.duell.input.event;

import android.annotation.TargetApi;
import android.os.Build;
import org.haxe.duell.DuellActivity;
import org.haxe.duell.hxjni.HaxeObject;

import java.lang.ref.WeakReference;
import java.util.ArrayDeque;
import java.util.Deque;

@TargetApi(Build.VERSION_CODES.GINGERBREAD)
public class CentralHaxeDispatcher implements Runnable
{
    public static final int TEXT_CHANGED_EVENT = 0;
    public static final int INPUT_STARTED_EVENT = 1;
    public static final int INPUT_ENDED_EVENT = 2;

    private static final String HAXE_TEXT_CHANGED_CALLBACK = "onTextChangedCallback";
    private static final String HAXE_INPUT_STARTED_CALLBACK = "onInputStartedCallback";
    private static final String HAXE_INPUT_ENDED_CALLBACK = "onInputEndedCallback";

    private final WeakReference<DuellActivity> activity;
    private final Deque<HaxeEvent> haxeEvents;
    private final HaxeObject haxeAppDelegate;

    private volatile boolean pendingQueueProcessing = false;

    static class HaxeEvent
    {
        private String data;
        private int type;

        public HaxeEvent(int type, String data)
        {
            this.data = data;
            this.type = type;
        }

        public String getData()
        {
            return data;
        }

        public int getType()
        {
            return type;
        }
    }

    public CentralHaxeDispatcher(HaxeObject haxeAppDelegate)
    {
        activity = new WeakReference<DuellActivity>(DuellActivity.getInstance());
        haxeEvents = new ArrayDeque<HaxeEvent>();
        this.haxeAppDelegate = haxeAppDelegate;
    }

    public void dispatchEvent(int type, String data)
    {
        synchronized (haxeEvents)
        {
            haxeEvents.add(new HaxeEvent(type, data));
        }

        if (!pendingQueueProcessing)
        {
            pendingQueueProcessing = true;

            DuellActivity activityLocal = activity.get();
            if (activityLocal != null)
            {
                activityLocal.queueOnHaxeThread(this);
            }
        }
    }

    @Override
    public void run()
    {
        // dispatching events
        synchronized (haxeEvents)
        {
            while (!haxeEvents.isEmpty())
            {
                HaxeEvent haxeEvent = haxeEvents.removeFirst();

                switch (haxeEvent.getType())
                {
                    case TEXT_CHANGED_EVENT:
                        haxeAppDelegate.call1(HAXE_TEXT_CHANGED_CALLBACK, haxeEvent.getData());
                        break;

                    case INPUT_STARTED_EVENT:
                        haxeAppDelegate.call0(HAXE_INPUT_STARTED_CALLBACK);
                        break;

                    case INPUT_ENDED_EVENT:
                        haxeAppDelegate.call0(HAXE_INPUT_ENDED_CALLBACK);
                        break;
                }
            }

            pendingQueueProcessing = false;
        }
    }
}
