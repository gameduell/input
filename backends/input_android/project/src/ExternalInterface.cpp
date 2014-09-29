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

static value inputandroid_initialize(value onTouchBatchStartCallback, value onTouchCallback)
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
	return alloc_null();
}
DEFINE_PRIM (inputandroid_initialize, 2);


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


