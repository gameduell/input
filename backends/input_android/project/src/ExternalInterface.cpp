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

#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#include <hx/CFFI.h>
#include <jni.h>

#ifdef __GNUC__
	#define JAVA_EXPORT __attribute__ ((visibility("default"))) JNIEXPORT
#else
	#define JAVA_EXPORT JNIEXPORT
#endif

#include "input_android/NativeTouch.h"

static value *__onTouchBatchStartCallback = NULL;
static value *__onTouchCallback = NULL;

static NativeTouch __touch;
static value __touchValue;

static int __touchCount;
static value __touchCountValue;

static value inputandroid_initialize(value onTouchBatchStartCallback, value onTouchCallback, value setCachedVariables)
{
	val_check_function(onTouchBatchStartCallback, 1); // Is Func ?

	if (__onTouchBatchStartCallback == NULL)
	{
		__onTouchBatchStartCallback = alloc_root();
	}
	*__onTouchBatchStartCallback = onTouchBatchStartCallback;

	val_check_function(onTouchCallback, 1); // Is Func ?

	if (__onTouchCallback == NULL)
	{
		__onTouchCallback = alloc_root();
	}
	*__onTouchCallback = onTouchCallback;

    __touchValue = alloc_abstract(0, &__touch);
    __touchCountValue = alloc_abstract(0, &__touchCount);

	val_call2(setCachedVariables, __touchValue, __touchCountValue);
	return alloc_null();
}
DEFINE_PRIM (inputandroid_initialize, 3);


struct AutoHaxe
{
	int base;
	const char *message;
	AutoHaxe(const char *inMessage)
	{
		base = 0;
		message = inMessage;
		gc_set_top_of_stack(&base,true);
		//__android_log_print(ANDROID_LOG_VERBOSE, "OpenGL", "Enter %s %p", message, pthread_self());
	}
	~AutoHaxe()
	{
		//__android_log_print(ANDROID_LOG_VERBOSE, "OpenGL", "Leave %s %p", message, pthread_self());
		gc_set_top_of_stack(0,true);
	}
};

extern "C" {
	JAVA_EXPORT void JNICALL Java_org_haxe_duell_input_DuellInputNativeInterface_startTouchInfoBatch(JNIEnv * env, jobject obj, jint count);
	JAVA_EXPORT void JNICALL Java_org_haxe_duell_input_DuellInputNativeInterface_touchInfo(JNIEnv * env, jobject obj, jint identifier, jfloat x, jfloat y, jint state);
};


JAVA_EXPORT void JNICALL Java_org_haxe_duell_input_DuellInputNativeInterface_startTouchInfoBatch(JNIEnv * env, jobject obj, jint count)
{
	AutoHaxe haxe("startTouchInfoBatch");

	__touchCount = count;

	val_call1(*__onTouchBatchStartCallback, __touchCountValue);
}

JAVA_EXPORT void JNICALL Java_org_haxe_duell_input_DuellInputNativeInterface_touchInfo(JNIEnv * env, jobject obj, jint identifier, jfloat x, jfloat y, jint state)
{
	AutoHaxe haxe("onTouchInfo");

	__touch.id = identifier;
	__touch.state = state;
	__touch.x = x;
	__touch.y = y;

	val_call1(*__onTouchCallback, __touchValue);
}

extern "C" int inputandroid_register_prims () { return 0; }
