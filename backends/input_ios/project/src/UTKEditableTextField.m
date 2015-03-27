//
//  UTKEditableTextField.m
//  Belote
//
//  Created by Andreas Hanft on 7/25/13.
//  Copyright (c) 2013 Gameduell Inc. All rights reserved.
//

#import "input_ios/UTKEditableTextField.h"

@protocol UTKKeyboardViewDelegate <NSObject>
- (void)keyboardViewDidInsertText:(NSString *)text;
- (void)keyboardViewDidDeleteBackward;
- (void)keyboardViewDidHideKeyBoard;

@optional
- (void)keyboardViewDidShowKeyBoard;
@end


@interface UTKKeyboardView : UIView <UIKeyInput>
@property (nonatomic, weak) id<UTKKeyboardViewDelegate> delegate;
- (BOOL)showKeyboard;
- (BOOL)hideKeyboard;
@end

@implementation UTKKeyboardView


#pragma mark - UIKeyInput delegate methods

-(BOOL)hasText
{
    return YES;
}

- (void)insertText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [self hideKeyboard];
    }
    else if([self.delegate respondsToSelector:@selector(keyboardViewDidInsertText:)])
    {
        [self.delegate keyboardViewDidInsertText:text];
    }
}

- (void)deleteBackward
{
    if ([self.delegate respondsToSelector:@selector(keyboardViewDidDeleteBackward)])
    {
        [self.delegate keyboardViewDidDeleteBackward];
    }
}


#pragma mark - UIResponder methods

- (BOOL)canResignFirstResponder
{
    if ([self.delegate respondsToSelector:@selector(keyboardViewDidHideKeyBoard)])
    {
        [self.delegate keyboardViewDidHideKeyBoard];
    }
    return YES;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}


#pragma mark - UTKKeyboardViewDelegate delegate methods

- (BOOL)showKeyboard
{
    if (![self isFirstResponder])
    {
        [self becomeFirstResponder];
        return YES;
    }

    return NO;
}

- (BOOL)hideKeyboard
{
    if ([self isFirstResponder])
    {
        [self resignFirstResponder];
        return YES;
    }

    return NO;
}

@end


@interface UTKEditableTextField () <UTKKeyboardViewDelegate>

@property (nonatomic, readonly,  strong) UTKKeyboardView *keyboardView;
@property (nonatomic, readwrite, strong) NSCharacterSet  *validCharacters;

@end


@implementation UTKEditableTextField

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setUpKeyboardView];
        [self reset];
    }
    
    return self;
}

- (void)setUpKeyboardView
{
    _keyboardView = [[UTKKeyboardView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _keyboardView.delegate = self;
}

- (void)reset
{
    self.string = @"";
}


#pragma mark - Keyboard methods

- (BOOL)showKeyboard
{
    return [_keyboardView showKeyboard];
}

- (BOOL)hideKeyboard
{
    return [_keyboardView hideKeyboard];
}

- (void)keyboardViewDidHideKeyBoard
{
    if ([self.delegate respondsToSelector:@selector(keyboardViewDidHide)])
    {
        [self.delegate keyboardViewDidHide];
    }
}


#pragma mark - UTKKeyboardViewDelegate methods

- (void)keyboardViewDidDeleteBackward
{
    NSString *string = self.string;
    
    if (string.length > 0)
    {
        self.string = [string stringByReplacingCharactersInRange:NSMakeRange([string length] - 1, 1) withString:@""];
        
        if ([self.delegate respondsToSelector:@selector(editableTextFieldDidChangeText:)])
        {
            [self.delegate editableTextFieldDidChangeText:self.string];
        }
    }
}

- (void)keyboardViewDidInsertText:(NSString *)text
{
    text = [self removeNotSupportedCharactersFromString:text];

    if ([self hasInputTextChanged:text])
    {
        [self appendInsertedText:text];

        if ([self.delegate respondsToSelector:@selector(editableTextFieldDidChangeText:)])
        {
            [self.delegate editableTextFieldDidChangeText:self.string];
        }
    }
}

- (NSString *)removeNotSupportedCharactersFromString:(NSString *)string
{
    string = [[string componentsSeparatedByCharactersInSet:[_validCharacters invertedSet]] componentsJoinedByString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return string;
}

- (BOOL)hasInputTextChanged:(NSString *)text
{
    BOOL textHasChanged = NO;
    
    if (text.length > 0)
    {
        if ([self.delegate respondsToSelector:@selector(editableTextFieldWillChangeText:)])
        {
            textHasChanged = [self.delegate editableTextFieldWillChangeText:text];
        }
    }
    
    return textHasChanged;
}

- (void)appendInsertedText:(NSString *)text
{
    self.string = [self.string stringByAppendingString:text];
}


#pragma mark - getter / setter

-(UIView *)keyBoardView
{
    return _keyboardView;
}

- (void)setValidCharacters:(NSCharacterSet *)set
{
    _validCharacters = set;
}

#pragma mark - 

- (void)attachToView:(UIView *)view
{
    [view addSubview:self.keyBoardView];
}

@end
