//
//  TextFieldListener.m
//
//  Created by João Xavier on 24/03/15.
//  Copyright (c) 2015 Gameduell Inc. All rights reserved.
//

#import "input_ios/TextFieldListener.h"

@interface TextFieldListener() <UTKEditableTextFieldDelegate>

@end


@implementation TextFieldListener

- (id)init
{
    self = [super init];
    if (self)
    {

    }
    
    return self;
}

- (void)dealloc
{
    _onTextChanged = nil;
    _onInputEnded = nil;
}

- (void)editableTextFieldDidChangeText:(NSString *)text
{
    self.onTextChanged(text);
}

- (BOOL)editableTextFieldWillChangeText:(NSString *)text
{
    return YES;
}

- (void)keyboardViewDidHide
{
    self.onInputEnded();
}

@end
