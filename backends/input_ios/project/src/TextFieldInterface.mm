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

void TextFieldWrapper::hideKeyboard()
{
    [textField hideKeyboard];
}

void TextFieldWrapper::showKeyboard()
{
    [textField showKeyboard];
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
    [field attachToView:view];

    TextFieldListener *listener = [[TextFieldListener alloc] init];
    listener.onInputEnded = ^
    {
        val_call0(hideKeyboardCallback);
    };

    listener.onTextChanged = ^(NSString *text)
    {
        value haxeString = alloc_string_len((const char *)[text UTF8String], [text length]);

        val_call1(textChangedCallback, haxeString);
    };

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
    wrapper->showKeyboard();

	return alloc_null();
}
DEFINE_PRIM (input_ios_text_show_keyboard, 1);


static value input_ios_text_hide_keyboard(value hxWrapper)
{
    TextFieldWrapper* wrapper = ((TextFieldWrapper*) val_data(hxWrapper));
    wrapper->hideKeyboard();

	return alloc_null();
}
DEFINE_PRIM (input_ios_text_hide_keyboard, 1);


static value input_ios_text_set_allowed_char_codes(value hxWrapper, value validChars)
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

    UTKEditableTextField *textField = wrapper->textField;
    [textField setValidCharacters:[charSet copy]];

	return alloc_null();
}
DEFINE_PRIM (input_ios_text_set_allowed_char_codes, 2);


static value input_ios_text_set_string(value hxWrapper, value hxString)
{
    TextFieldWrapper* wrapper = ((TextFieldWrapper*) val_data(hxWrapper));
    UTKEditableTextField *textField = wrapper->textField;

    NSString *string = [NSString stringWithCString:val_get_string(hxString) encoding:NSUTF8StringEncoding];

    textField.string = string;

	return alloc_null();
}
DEFINE_PRIM (input_ios_text_set_string, 2);
