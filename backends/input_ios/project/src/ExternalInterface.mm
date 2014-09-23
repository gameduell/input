#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#include <hx/CFFI.h>

#import "input_ios/InputCapturer.h"

value *__onTouchesCallback = NULL;

static value inputios_initialize(value onTouchesCallback)
{
	val_check_function(onTouchesCallback, 1); // Is Func ?

	if (__onTouchesCallback == NULL)
	{
		__onTouchesCallback = alloc_root();
	}
	*__onTouchesCallback = onTouchesCallback;

	[InputCapturer initializeCapturer];

	return alloc_null();
}
DEFINE_PRIM (inputios_initialize, 1);

void callHaxeOnTouchesCallback(value touchList)
{
	val_call1(*__onTouchesCallback, touchList);
}

extern "C" int inputios_register_prims () { return 0; }