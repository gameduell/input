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

#import <input_ios/DUELLGestureRecognizer.h>

#include <input_ios/NativeTouch.h>

#import <objc/runtime.h>
#import "DUELLAppDelegate.h"

#include <hx/CFFI.h>

#define TOUCH_LIST_POOL_SIZE 40
#define FLUSH_TOUCH_STATE 100

static NativeTouch *touchList = NULL;
static int touchCount;

static NativeTouch * touchBuffer = NULL;
static int touchBufferSize = 0;
static int touchBufferPos = 0;

DEFINE_KIND(k_TouchCount)
DEFINE_KIND(k_TouchList)

static value touchCountValue;
static value touchListValue;

extern void callHaxeOnTouchesCallback(value touchCount, value touchList);
extern void callSetCachedVariablesCallback(value touchCount, value touchList);

int convertPointerToUniqueInt(UITouch *touch)
{
    int hash = 16777619; ////FNV PRIME, http://www.isthe.com/chongo/tech/comp/fnv/index.html#FNV-source
    hash ^= [touch hash];

    return hash;
}

void convertUITouch(UITouch *touch, NativeTouch& out, UIView* view)
{
    CGPoint locationInView = [touch locationInView:view];
    out.x = locationInView.x * [[UIScreen mainScreen] scale];
    out.y = locationInView.y * [[UIScreen mainScreen] scale];

    switch(touch.phase)
    {
        case(UITouchPhaseBegan):
            out.state = 0;
            break;
        case(UITouchPhaseMoved):
            out.state = 1;
            break;
        case(UITouchPhaseStationary):
            out.state = 2;
            break;
        case(UITouchPhaseEnded):
            out.state = 3;
            break;
        case(UITouchPhaseCancelled):
            out.state = 4;
    }

    out.id = convertPointerToUniqueInt(touch);
}

void initTouchBuffer()
{
    touchBuffer = new NativeTouch[TOUCH_LIST_POOL_SIZE];
    touchBufferSize = TOUCH_LIST_POOL_SIZE;
    touchBufferPos = 0;
}

void preallocateTouchBuffer(int incommingSize)
{
    int newSize = touchBufferPos + incommingSize;
    if (newSize < touchBufferSize)
    {
        return; //enough size
    }

    newSize = (int)( newSize * 1.6);
    NativeTouch* newBuffer = new NativeTouch[newSize];
    for (int i = 0; i < touchBufferPos; i++)
    {
        newBuffer[i] = touchBuffer[i];
    }

    delete [] touchBuffer;

    touchBuffer = newBuffer;
    touchBufferSize = newSize;
}

@implementation DUELLGestureRecognizer

- (void) initializeTouchCapturing
{
    touchList = new NativeTouch[TOUCH_LIST_POOL_SIZE];
    initTouchBuffer();

    touchCountValue = alloc_abstract(k_TouchCount, &touchCount);
    touchListValue = alloc_abstract(k_TouchList, touchList);

    callSetCachedVariablesCallback(touchCountValue, touchListValue);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dispatchTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dispatchTouches:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dispatchTouches:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dispatchTouches:touches];
}

int findSkipTouch(int begin, int end)
{
    for(int i = begin; i < end; i++)
    {
        if(touchBuffer[i].state == FLUSH_TOUCH_STATE)
        {
            return i;
        }
    }

    return -1;
}

- (void) dispatchTouches:(NSSet *)touches
{
    preallocateTouchBuffer(touches.count + 1);

    int i = touchBufferPos;
    for (UITouch *touch in touches)
    {
        convertUITouch(touch, touchBuffer[i], self.view);
        i++;
        touchBufferPos++;
    }

    touchBuffer[i].state = FLUSH_TOUCH_STATE;
    touchBufferPos++;


    [DUELLAppDelegate executeBlock: ^{
        if (touchBufferPos == 0)
        {
            return;
        }

        int callbackPos = 0;
        int nextSkipTouch = findSkipTouch(callbackPos, touchBufferPos);
        while (callbackPos < touchBufferPos)
        {
            const int end = nextSkipTouch != -1 ? nextSkipTouch : touchBufferPos;
            const int leftToCopy = end - callbackPos;
            const int chunkSize = leftToCopy > TOUCH_LIST_POOL_SIZE ? TOUCH_LIST_POOL_SIZE : leftToCopy;

            memcpy(touchList, touchBuffer + callbackPos, chunkSize * sizeof(NativeTouch));
            touchCount = chunkSize;
            callHaxeOnTouchesCallback(touchCountValue, touchListValue);

            callbackPos += chunkSize;

            if(touchBuffer[callbackPos].state == FLUSH_TOUCH_STATE)
            {
                callbackPos++;
                nextSkipTouch = findSkipTouch(callbackPos, touchBufferPos);
            }
        }

        touchBufferPos = 0;
    }];
}

- (void) dealloc
{
    delete[] touchList;
}

@end
