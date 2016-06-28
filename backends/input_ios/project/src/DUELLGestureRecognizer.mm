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

static NativeTouch *touchList = NULL;
static int touchCount;

DEFINE_KIND(k_TouchCount)
DEFINE_KIND(k_TouchList)

static value touchCountValue;
static value touchListValue;

@implementation DUELLGestureRecognizer

extern void callSetCachedVariablesCallback(value touchCount, value touchList);
- (void) initializeTouchCapturing
{
    touchList = new NativeTouch[TOUCH_LIST_POOL_SIZE];

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

int convertPointerToUniqueInt(UITouch *touch)
{
    int hash = 16777619; ////FNV PRIME, http://www.isthe.com/chongo/tech/comp/fnv/index.html#FNV-source
    hash ^= [touch hash];

    return hash;
}

extern void callHaxeOnTouchesCallback(value touchCount, value touchList);
- (void) dispatchTouches:(NSSet *)touches
{
    touchCount = touches.count;

    int i = 0;
    for (UITouch *touch in touches)
    {
        CGPoint locationInView = [touch locationInView:self.view];
        touchList[i].x = locationInView.x * [[UIScreen mainScreen] scale];
        touchList[i].y = locationInView.y * [[UIScreen mainScreen] scale];

        switch(touch.phase)
        {
            case(UITouchPhaseBegan):
                touchList[i].state = 0;
                break;
            case(UITouchPhaseMoved):
                touchList[i].state = 1;
                break;
            case(UITouchPhaseStationary):
                touchList[i].state = 2;
                break;
            case(UITouchPhaseEnded):
                touchList[i].state = 3;
                break;
            case(UITouchPhaseCancelled):
                touchList[i].state = 4;
        }
        touchList[i].id = convertPointerToUniqueInt(touch);

        ++i;
    }

    [DUELLAppDelegate executeBlock: ^{
        callHaxeOnTouchesCallback(touchCountValue, touchListValue);
    }];
}

- (void) dealloc
{
    delete[] touchList;
}

@end
