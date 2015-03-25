/*
 * Copyright (c) 2003-2015 GameDuell GmbH, All Rights Reserved
 * This document is strictly confidential and sole property of GameDuell GmbH, Berlin, Germany
 */
package org.haxe.duell.input;

import android.annotation.TargetApi;
import android.os.Build;

import java.util.ArrayDeque;
import java.util.Deque;

@TargetApi(Build.VERSION_CODES.GINGERBREAD)
class DuellInputTouch
{

    /// ========
    /// DUELL INPUT TOUCH DATA POOL

    static class DuellInputTouchData
    {
        public float x;
        public float y;
        public int state;

        private static final Deque<DuellInputTouchData> poolAvailable = new ArrayDeque<DuellInputTouchData>();

        public static DuellInputTouchData getPooledTouch()
        {
            DuellInputTouchData po;
            if (!poolAvailable.isEmpty())
            {
                po = poolAvailable.removeFirst();
            }
            else
            {
                po = new DuellInputTouchData();
            }
            return po;
        }

        public static void recycle(DuellInputTouchData po)
        {
            poolAvailable.addLast(po);
        }
    }

    /// DUELL INPUT TOUCH DATA POOL
    /// ========

    /// ========
    /// DUELL INPUT TOUCH POOL

    private static final Deque<DuellInputTouch> poolAvailable = new ArrayDeque<DuellInputTouch>();

    public static DuellInputTouch getPooledTouch()
    {
        DuellInputTouch po;
        if (!poolAvailable.isEmpty())
        {
            po = poolAvailable.removeFirst();
        }
        else
        {
            po = new DuellInputTouch();
        }
        return po;
    }

    public static void recycle(DuellInputTouch po)
    {

        if (po.lastDataUploaded != null)
        {
            DuellInputTouchData.recycle(po.lastDataUploaded);
            po.lastDataUploaded = null;
        }

        for (DuellInputTouchData d : po.pendingData)
        {
            DuellInputTouchData.recycle(d);
        }

        po.pendingData.clear();

        poolAvailable.addLast(po);
    }

    /// DUELL INPUT TOUCH POOL
    /// ========

    public int id;

    private DuellInputTouchData lastDataUploaded = null;
    private Deque<DuellInputTouchData> pendingData = new ArrayDeque<DuellInputTouchData>();

    public void pushData(float x, float y, int newState)
    {

        int latestState = -1;

        if (!pendingData.isEmpty())
        {
            latestState = pendingData.getLast().state;
        }
        else if (lastDataUploaded != null)
        {
            latestState = lastDataUploaded.state;
        }

        if (latestState == -1 && newState != 0)
        {
            /// this is actually not needed because it needs to be checked from the outside
            return; /// can only go from undefined to began
        }

        if (latestState == 3 || latestState == 4)
        {
            return; /// once it ends, it ends forever, no need for more updates
        }

        if (latestState == 1 && newState < latestState)
        {
            return; /// cannot go from moved to began or undefined
        }

        if (latestState == 0 && newState == 0)
        {
            return; /// only one began allowed
        }

        DuellInputTouchData d = DuellInputTouchData.getPooledTouch();

        d.x = x;
        d.y = y;
        d.state = newState;

        pendingData.addLast(d);
    }

    public boolean isFinished()
    {

        return lastDataUploaded.state == 3 || lastDataUploaded.state == 4;
    }

    public void cancel()
    {

        for (DuellInputTouchData d : pendingData)
        {
            DuellInputTouchData.recycle(d);
        }

        pendingData.clear();

        pushData(0, 0, 4); /// force cancel
    }

    public boolean hasPendingData()
    {

        return !pendingData.isEmpty();
    }

    public void uploadData()
    {

        if (hasPendingData())
        {

            DuellInputTouchData d = pendingData.removeFirst();
            DuellInputNativeInterface.touchInfo(id, d.x, d.y, d.state);

            if (lastDataUploaded != null)
            {
                DuellInputTouchData.recycle(lastDataUploaded);
            }

            lastDataUploaded = d;
        }
        else
        {
            /// this only happens when one touch had pending, and we have to send all of them.
            /// we send as moved in this case

            DuellInputNativeInterface.touchInfo(id, lastDataUploaded.x, lastDataUploaded.y, 1);
        }
    }
}