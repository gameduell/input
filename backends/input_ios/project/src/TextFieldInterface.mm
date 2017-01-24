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

#import "input_ios/UTKEditableTextField.h"
#import "input_ios/TextFieldListener.h"

#include "input_ios/TextFieldWrapper.h"
#include <hx/CFFI.h>


static void finalizer(value abstract_object)
{
     TextFieldWrapper* np = (TextFieldWrapper*) val_data(abstract_object);
     delete np;
}

DEFINE_KIND(k_TextFieldWrapper);
value TextFieldWrapper::createHaxePointer()
{
	value v;
	v = alloc_abstract(k_TextFieldWrapper, new TextFieldWrapper());
	val_gc(v, (hxFinalizer) &finalizer);
	return v;
}

TextFieldWrapper::~TextFieldWrapper()
{
	textField = nil;
	listener = nil;
}



static value input_ios_text_create_textfieldwrapper(value hideKeyboardCallback, value textChangedCallback)
{
    val_check_function(hideKeyboardCallback, 0);
    val_check_function(textChangedCallback, 1);

    UIView *view = [UIApplication sharedApplication].keyWindow.rootViewController.view;

    UTKEditableTextField *field = [[UTKEditableTextField alloc] init];
    // has to be attached to the UIView once
    [field attachToView:view];

    // the listener should be forwarding the block calls to haxe code
    TextFieldListener *listener = [[TextFieldListener alloc] init];
    listener.onInputEnded = ^
    {
        val_call0(hideKeyboardCallback);
    };

    listener.onTextChanged = ^(NSString *text)
    {
        const char* cStr = (const char *)[text UTF8String];
        value haxeString = alloc_string_len(cStr, strlen(cStr));

        val_call1(textChangedCallback, haxeString);
    };

    // set the listener as delegate
    field.delegate = listener;

	value hxWrapper = TextFieldWrapper::createHaxePointer();
	TextFieldWrapper* wrapper = ((TextFieldWrapper*) val_data(hxWrapper));
    wrapper->textField = field;
    wrapper->listener = listener;

	return hxWrapper;
}
DEFINE_PRIM (input_ios_text_create_textfieldwrapper, 2);


static value input_ios_text_show_keyboard(value hxWrapper)
{
    TextFieldWrapper* wrapper = ((TextFieldWrapper*) val_data(hxWrapper));
    UTKEditableTextField *textField = wrapper->textField;

    return alloc_bool([textField showKeyboard]);
}
DEFINE_PRIM (input_ios_text_show_keyboard, 1);


static value input_ios_text_hide_keyboard(value hxWrapper)
{
    TextFieldWrapper* wrapper = ((TextFieldWrapper*) val_data(hxWrapper));
    UTKEditableTextField *textField = wrapper->textField;

    return alloc_bool([textField hideKeyboard]);
}
DEFINE_PRIM (input_ios_text_hide_keyboard, 1);


static value input_ios_text_set_allowed_chars(value hxWrapper, value validChars, value hxAllowedString)
{
    TextFieldWrapper* wrapper = ((TextFieldWrapper*) val_data(hxWrapper));

    NSMutableCharacterSet *charSet = [[NSMutableCharacterSet alloc] init];

    int validCharSize = val_array_size(validChars);

    for (int i = 0; i < validCharSize; ++i)
    {
        value isSet = val_array_i(validChars, i);
        BOOL enabled = val_get_bool(isSet);

        if (enabled)
        {
            [charSet addCharactersInRange:NSMakeRange(i, 1)];
        }
    }

    NSString *allowedString = [NSString stringWithCString: val_get_string(hxAllowedString) encoding: NSUTF8StringEncoding];
    [charSet addCharactersInString: allowedString];

    UTKEditableTextField *textField = wrapper->textField;
    [textField setValidCharacters:[charSet copy]];

	return alloc_null();
}
DEFINE_PRIM (input_ios_text_set_allowed_chars, 3);


static value input_ios_text_set_text(value hxWrapper, value hxString)
{
    TextFieldWrapper* wrapper = ((TextFieldWrapper*) val_data(hxWrapper));
    UTKEditableTextField *textField = wrapper->textField;

    NSString *string = [NSString stringWithCString:val_get_string(hxString) encoding:NSUTF8StringEncoding];
    textField.string = string;

	return alloc_null();
}
DEFINE_PRIM (input_ios_text_set_text, 2);
