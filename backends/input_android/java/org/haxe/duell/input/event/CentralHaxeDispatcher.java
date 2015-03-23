/*
 * Copyright (c) 2003-2014 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */

package org.haxe.duell.input.event;

import android.annotation.TargetApi;
import android.os.Build;
import org.haxe.duell.DuellActivity;
import org.haxe.duell.hxjni.HaxeObject;

import java.lang.ref.WeakReference;
import java.util.ArrayDeque;
import java.util.Deque;

/**
 * @author jxav
 */
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
