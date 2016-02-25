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

#import "input_ios/UTKEditableTextField.h"

NSRange clampRange(NSRange range, int maxLength)
{
    int location = range.location;
    int length = range.length;

    if (location > maxLength)
    {
        location = maxLength;
    }

    if (location + length > maxLength)
    {
        length = maxLength - location;
    }

    return NSMakeRange(location, length);
}

#pragma mark - UITextPosition and UITextRange

@interface UTKIndexedPosition : UITextPosition {
    NSUInteger _index;
}
@property (nonatomic) NSUInteger index;
+ (UTKIndexedPosition *)positionWithIndex:(NSUInteger)index;

@end

@interface UTKIndexedRange : UITextRange {
    NSRange _range;
}
@property (nonatomic) NSRange range;
+ (UTKIndexedRange *)rangeWithNSRange:(NSRange)range;

@end

@implementation UTKIndexedPosition

@synthesize index = _index;

+ (UTKIndexedPosition *)positionWithIndex:(NSUInteger)index {
    UTKIndexedPosition *pos = [[UTKIndexedPosition alloc] init];
    pos.index = index;
    return pos;
}

@end

@implementation UTKIndexedRange

@synthesize range = _range;

+ (UTKIndexedRange *)rangeWithNSRange:(NSRange)nsrange {
    if (nsrange.location == NSNotFound)
        return nil;
    UTKIndexedRange *range = [[UTKIndexedRange alloc] init];
    range.range = nsrange;
    return range;
}

- (UITextPosition *)start {
    return [UTKIndexedPosition positionWithIndex:self.range.location];
}

- (UITextPosition *)end {
        return [UTKIndexedPosition positionWithIndex:(self.range.location + self.range.length)];
}

-(BOOL)isEmpty {
    return (self.range.length == 0);
}

@end

#pragma mark - UTKKeyboardView

@protocol UTKKeyboardViewDelegate <NSObject>
@property (nonatomic) NSString* string;
- (bool)        isTextValid:(NSString* )text;
- (void)        keyboardHidden;

@end


@interface UTKKeyboardView : UIView <UITextInput>
@property (nonatomic) NSRange selectedNSRange; // Selected text range.
@property (nonatomic, weak) id<UTKKeyboardViewDelegate> delegate;
@property (nonatomic) UITextInputStringTokenizer *tokenizer;
- (BOOL)showKeyboard;
- (BOOL)hideKeyboard;
@end

@implementation UTKKeyboardView

@synthesize markedTextStyle = _markedTextStyle;
@synthesize inputDelegate = _inputDelegate;
@synthesize tokenizer = _tokenizer;

#pragma mark - UITextInput important delegate methods

-(BOOL)hasText
{
    return YES;
}

- (UITextInputStringTokenizer *) tokenizer
{
    if (_tokenizer == nil)
    {
        _tokenizer = [[UITextInputStringTokenizer alloc] initWithTextInput:self];
    }

    return _tokenizer;
}

- (void)insertText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [self hideKeyboard];
    }
    else
    {
        NSMutableString* currentText = [NSMutableString stringWithString:
                                                            self.delegate.string];

        if (self.selectedNSRange.length > 0)
        {
            [currentText replaceCharactersInRange:self.selectedNSRange withString:text];
        }
        else
        {
            [currentText insertString:text atIndex:self.selectedNSRange.location];
        }

        self.delegate.string = currentText;

        [self resetSelection];
    }
}

- (BOOL)shouldChangeTextInRange:(UITextRange *)range
                replacementText:(NSString *)text
{

    UTKIndexedRange *indexedRange = (UTKIndexedRange *)range;
    NSMutableString* currentText = [NSMutableString stringWithString:
                                                self.delegate.string];

    [currentText replaceCharactersInRange:indexedRange.range withString:text];

    return [self.delegate isTextValid:currentText];
}

- (void)deleteBackward
{

    /// check if the label is empty
    if (self.delegate.string.length > 0)
    {
        [self resetSelection]; /// always go from the right when deleting

        self.delegate.string = [self.delegate.string
                            stringByReplacingCharactersInRange:NSMakeRange([self.delegate.string length] - 1, 1)
                                                    withString:@""];

        [self resetSelection]; /// go to the new end of the string
    }

}


- (void)setSelectedTextRange:(UITextRange *)range
{
    UTKIndexedRange *r = (UTKIndexedRange *)range;

    NSString* currentText = self.delegate.string;

    NSRange nsrange = clampRange(r.range, currentText.length);

    self.selectedNSRange = nsrange;
}

- (NSString *)textInRange:(UITextRange *)range
{
    UTKIndexedRange *r = (UTKIndexedRange *)range;
    NSString* currentText = self.delegate.string;

    NSRange nsrange = clampRange(r.range, currentText.length);

    return [self.delegate.string substringWithRange:nsrange];
}

- (void)replaceRange:(UITextRange *)range withText:(NSString *)text
{
    NSMutableString* currentText = [NSMutableString stringWithString:
                                                            self.delegate.string];

    UTKIndexedRange *r = (UTKIndexedRange *)range;

    NSRange nsrange = clampRange(r.range, currentText.length);

    [currentText replaceCharactersInRange:nsrange withString:text];

    self.delegate.string = currentText;

    [self resetSelection];
}

/// not delegate
- (void)resetSelection
{
    self.selectedNSRange =
        NSMakeRange(self.delegate.string.length,
                    0);
}

- (void)unmarkText
{
    [self resetSelection];
}

#pragma mark - UITextInput boilerplate delegate methods

- (UITextRange *)selectedTextRange {

    return [UTKIndexedRange rangeWithNSRange:self.selectedNSRange];
}

- (UITextRange *)markedTextRange {
    /// we don't care about marking
    return [UTKIndexedRange rangeWithNSRange:NSMakeRange(NSNotFound, 0)];
}

- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange
{
    /// we don't care about market text
    return;
}

- (UITextPosition *)beginningOfDocument
{
	// For this sample, the document always starts at index 0 and is the full length of the text storage.
    return [UTKIndexedPosition positionWithIndex:0];
}

- (UITextPosition *)endOfDocument
{
	// For this sample, the document always starts at index 0 and is the full length of the text storage.
    return [UTKIndexedPosition positionWithIndex:self.delegate.string.length];
}

- (UITextRange *)textRangeFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition
{
	// Generate IndexedPosition instances that wrap the to and from ranges.
    UTKIndexedPosition *fromIndexedPosition = (UTKIndexedPosition *)fromPosition;
    UTKIndexedPosition *toIndexedPosition = (UTKIndexedPosition *)toPosition;
    NSRange range = NSMakeRange(MIN(fromIndexedPosition.index, toIndexedPosition.index), ABS(toIndexedPosition.index - fromIndexedPosition.index));

    return [UTKIndexedRange rangeWithNSRange:range];
}

- (UITextPosition *)positionFromPosition:(UITextPosition *)position offset:(NSInteger)offset
{
	// Generate IndexedPosition instance, and increment index by offset.
    UTKIndexedPosition *indexedPosition = (UTKIndexedPosition *)position;
    NSInteger end = indexedPosition.index + offset;
	// Verify position is valid in document.
    if (end > self.delegate.string.length || end < 0) {
        return nil;
    }

    return [UTKIndexedPosition positionWithIndex:end];
}

- (UITextPosition *)positionFromPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset
{
    // Note that this sample assumes left-to-right text direction.
    UTKIndexedPosition *indexedPosition = (UTKIndexedPosition *)position;
    NSInteger newPosition = indexedPosition.index;

    switch ((NSInteger)direction) {
        case UITextLayoutDirectionRight:
            newPosition += offset;
            break;
        case UITextLayoutDirectionLeft:
            newPosition -= offset;
            break;
        UITextLayoutDirectionUp:
        UITextLayoutDirectionDown:
			// This sample does not support vertical text directions.
            break;
    }

    // Verify new position valid in document.

    if (newPosition < 0)
        newPosition = 0;

    if (newPosition > self.delegate.string.length)
        newPosition = self.delegate.string.length;

    return [UTKIndexedPosition positionWithIndex:newPosition];
}

- (NSComparisonResult)comparePosition:(UITextPosition *)position toPosition:(UITextPosition *)other
{
    UTKIndexedPosition *indexedPosition = (UTKIndexedPosition *)position;
    UTKIndexedPosition *otherIndexedPosition = (UTKIndexedPosition *)other;

	// For this sample, simply compare position index values.
    if (indexedPosition.index < otherIndexedPosition.index) {
        return NSOrderedAscending;
    }
    if (indexedPosition.index > otherIndexedPosition.index) {
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

- (NSInteger)offsetFromPosition:(UITextPosition *)from
                     toPosition:(UITextPosition *)toPosition
{
    UTKIndexedPosition *fromIndexedPosition = (UTKIndexedPosition *)from;
    UTKIndexedPosition *toIndexedPosition = (UTKIndexedPosition *)toPosition;
    return (toIndexedPosition.index - fromIndexedPosition.index);
}

- (UITextPosition *)positionWithinRange:(UITextRange *)range
                    farthestInDirection:(UITextLayoutDirection)direction
{
    // Simplified to assume left-to-right text direction.
    UTKIndexedRange *indexedRange = (UTKIndexedRange *)range;
    NSInteger position;

    switch (direction) {
        case UITextLayoutDirectionUp:
        case UITextLayoutDirectionLeft:
            position = indexedRange.range.location;
            break;
        case UITextLayoutDirectionRight:
        case UITextLayoutDirectionDown:
            position = indexedRange.range.location + indexedRange.range.length;
            break;
    }

    return [UTKIndexedPosition positionWithIndex:position];
}

- (UITextRange *)characterRangeByExtendingPosition:(UITextPosition *)position
                                       inDirection:(UITextLayoutDirection)direction
{
    // Simplified to assume left-to-right text direction.
    UTKIndexedPosition *pos = (UTKIndexedPosition *)position;
    NSRange result;

    switch (direction) {
        case UITextLayoutDirectionUp:
        case UITextLayoutDirectionLeft:
            result = NSMakeRange(pos.index - 1, 1);
            break;
        case UITextLayoutDirectionRight:
        case UITextLayoutDirectionDown:
            result = NSMakeRange(pos.index, 1);
            break;
    }

    return [UTKIndexedRange rangeWithNSRange:result];
}

- (UITextWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction
{
    /// writing direction not implemented
    return UITextWritingDirectionLeftToRight;
}

- (void)setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange *)range
{
    /// writing direction not implemented
}

- (CGRect)firstRectForRange:(UITextRange *)range
{
    /// simplified for this use case
    return CGRectMake(0, 0, 0, 0);
}

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    /// simplified for this use case
    return CGRectMake(0, 0, 0, 0);
}

- (UITextPosition *)closestPositionToPoint:(CGPoint)point
{
    /// we don't care about hit testing
    return nil;
}

- (UITextRange *)characterRangeAtPoint:(CGPoint)point
{
    /// we don't care about hit testing
    return nil;
}

- (UITextPosition *)closestPositionToPoint:(CGPoint)point
                               withinRange:(UITextRange *)range
{
    /// we don't care about hit testing
    return nil;
}

#pragma mark - UIResponder methods

- (BOOL)canResignFirstResponder
{
    if ([self.delegate respondsToSelector:@selector(keyboardHidden)])
    {
        [self.delegate keyboardHidden];
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

@property (nonatomic,  strong) UTKKeyboardView *utkKeyboardView;
@property (nonatomic, readwrite, strong) NSCharacterSet  *validCharacters;

@end

@implementation UTKEditableTextField

@synthesize string = _string;
@synthesize keyboardView = _keyboardView;
@synthesize utkKeyboardView = _utkKeyboardView;

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
    _utkKeyboardView = [[UTKKeyboardView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _utkKeyboardView.delegate = self;

    _keyboardView = _utkKeyboardView;
}

- (void)reset
{
    _string = @"";
}

#pragma mark - Keyboard methods

- (BOOL)showKeyboard
{
    return [_utkKeyboardView showKeyboard];
}

- (BOOL)hideKeyboard
{
    return [_utkKeyboardView hideKeyboard];
}

- (void)keyboardHidden
{
    if ([self.delegate respondsToSelector:@selector(keyboardViewDidHide)])
    {
        [self.delegate keyboardViewDidHide];
    }
}

#pragma mark - UTKKeyboardViewDelegate methods

- (void)setString:(NSString *)text
{
    text = [self removeNotSupportedCharactersFromString:text];

    /// check if we need to change anything
    if (![text isEqualToString:_string])
    {
        bool textHasChanged = true;
        if ([self.delegate respondsToSelector:@selector(editableTextFieldWillChangeText:)])
        {
            textHasChanged = [self.delegate editableTextFieldWillChangeText:text];
        }

        if (textHasChanged)
        {
            _string = text;

            if ([self.delegate respondsToSelector:@selector(editableTextFieldDidChangeText:)])
            {
                [self.delegate editableTextFieldDidChangeText:_string];
            }
        }
    }
}

- (bool)isTextValid:(NSString *)text
{
    int length = text.length;
    text = [self removeNotSupportedCharactersFromString:text];
    return text.length == length;
}

#pragma mark - getter / setter

- (void)setValidCharacters:(NSCharacterSet *)set
{
    _validCharacters = set;
}

#pragma mark -

- (NSString *) removeNotSupportedCharactersFromString:(NSString *)text
{
    /// remove invalid characters
    if (_validCharacters != nil)
    {
        text = [[text componentsSeparatedByCharactersInSet:[_validCharacters invertedSet]] componentsJoinedByString:@""];
    }
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    return text;
}

- (void)attachToView:(UIView *)view
{
    [view addSubview:self.keyboardView];
}

@end
