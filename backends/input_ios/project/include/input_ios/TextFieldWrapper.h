#ifndef __TYPES_TEXT_FIELD_WRAPPER_
#define __TYPES_TEXT_FIELD_WRAPPER_

#import <Foundation/Foundation.h>
#import <hx/CFFI.h>
#import "input_ios/UTKEditableTextField.h"
#import "input_ios/TextFieldListener.h"

class TextFieldWrapper
{
	public:
	    UTKEditableTextField* textField;
        TextFieldListener* listener;

	    void showKeyboard();
	    void hideKeyboard();

		static value createHaxePointer();

		~TextFieldWrapper();
};

#endif //__TYPES_TEXT_FIELD_WRAPPER_
