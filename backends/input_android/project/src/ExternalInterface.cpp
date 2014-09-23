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

static value *__onTouchesCallback = NULL;

static value __touchListPool;
static value __touchListToSend;

#define TOUCH_LIST_POOL_SIZE 40

static value inputandroid_initialize(value onTouchesCallback)
{
	val_check_function(onTouchesCallback, 1); // Is Func ?

	if (__onTouchesCallback == NULL)
	{
		__onTouchesCallback = alloc_root();
	}
	*__onTouchesCallback = onTouchesCallback;

	__touchListPool = alloc_array(TOUCH_LIST_POOL_SIZE);

    for (int i = 0; i < TOUCH_LIST_POOL_SIZE; i++)
    {
        val_array_set_i(__touchListPool, i, input_android::NativeTouch::createHaxePointer());
    }

    __touchListToSend = alloc_array(TOUCH_LIST_POOL_SIZE);

	return alloc_null();
}
DEFINE_PRIM (inputandroid_initialize, 1);

extern "C" int inputandroid_register_prims () { return 0; }


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

static int __touchesLeft = 0;
static int __totalTouches = 0;

JAVA_EXPORT void JNICALL Java_org_haxe_duell_input_DuellInputNativeInterface_startTouchInfoBatch(JNIEnv * env, jobject obj, jint count)
{
	AutoHaxe haxe("startTouchInfoBatch");

	__touchesLeft = count;
	__totalTouches = count;
    val_array_set_size(__touchListToSend, count);
}

JAVA_EXPORT void JNICALL Java_org_haxe_duell_input_DuellInputNativeInterface_touchInfo(JNIEnv * env, jobject obj, jint identifier, jfloat x, jfloat y, jint state)
{
	AutoHaxe haxe("onTouchInfo");

    value nativeTouchValue = val_array_i(__touchListPool, __totalTouches - __touchesLeft);
    val_array_set_i(__touchListToSend, __totalTouches - __touchesLeft, nativeTouchValue);

    input_android::NativeTouch *nativeTouch = (input_android::NativeTouch *)val_data(nativeTouchValue);
    nativeTouch->x = x;
    nativeTouch->y = y;
    nativeTouch->state = state;
    nativeTouch->id = identifier;

    __touchesLeft--;
	if (__touchesLeft == 0)
	{
		val_call1(*__onTouchesCallback, __touchListToSend);
	}

}

extern "C" int openglcontextandroid_register_prims () { return 0; }




