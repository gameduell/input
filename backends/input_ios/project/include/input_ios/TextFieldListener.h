//
//  TextFieldListener.h
//
//  Created by João Xavier on 24/03/15.
//  Copyright (c) 2015 Gameduell Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "input_ios/UTKEditableTextField.h"

@interface TextFieldListener : NSObject<UTKEditableTextFieldDelegate>

@property (nonatomic, readwrite, copy) void (^onInputEnded) (void);
@property (nonatomic, readwrite, copy) void (^onTextChanged) (NSString *);

@end


