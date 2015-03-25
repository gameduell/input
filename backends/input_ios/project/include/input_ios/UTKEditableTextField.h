//
//  UTKEditableTextField.h
//  Belote
//
//  Created by Andreas Hanft on 7/25/13.
//  Copyright (c) 2013 Gameduell Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol UTKEditableTextFieldDelegate <NSObject>

@required
- (void)editableTextFieldDidChangeText:(NSString *)text;

@optional
- (BOOL)editableTextFieldWillChangeText:(NSString *)text;
// callback for keyboard hiding
- (void)keyboardViewDidHide;

@end


@interface UTKEditableTextField : NSObject

@property (nonatomic, strong) NSString *string;
@property (nonatomic, readwrite, weak) id<UTKEditableTextFieldDelegate> delegate;

- (void)showKeyboard;
- (void)hideKeyboard;

- (UIView *)keyBoardView;
- (void)setValidCharacters:(NSCharacterSet *)set;
- (void)attachToView:(UIView *)view;

@end


