#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#include <hx/CFFI.h>

#import "input_ios/InputCapturer.h"

value *__onTouchesCallback = NULL;
value *__setCachedVariables = NULL;

static value inputios_initialize(value onTouchesCallback, value setCachedVariables)
{
	val_check_function(onTouchesCallback, 2); // Is Func ?

	if (__onTouchesCallback == NULL)
	{
		__onTouchesCallback = alloc_root();
	}
	*__onTouchesCallback = onTouchesCallback;

	val_check_function(setCachedVariables, 2); // Is Func ?

	if (__setCachedVariables == NULL)
	{
		__setCachedVariables = alloc_root();
	}
	*__setCachedVariables = setCachedVariables;

	[InputCapturer initializeCapturer];

	return alloc_null();
}
DEFINE_PRIM (inputios_initialize, 2);

void callHaxeOnTouchesCallback(value touchCount, value touchList)
{
	val_call2(*__onTouchesCallback, touchCount, touchList);
}

void callSetCachedVariablesCallback(value touchCount, value touchList)
{
	val_call2(*__setCachedVariables, touchCount, touchList);
}

extern "C" int inputios_register_prims () { return 0; }