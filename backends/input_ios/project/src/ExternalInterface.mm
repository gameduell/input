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
