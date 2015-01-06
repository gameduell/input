#import <input_ios/InputCapturer.h>

#import <input_ios/DUELLGestureRecognizer.h>



@implementation InputCapturer

+ (void) initializeCapturer
{
	if ([UIApplication sharedApplication].keyWindow == nil)
	{
		@throw(@"Error: There is currently no window associated with this application. \
			    Please initialize a library (e.g. opengl) that initializes a window, so the input library can attach to that.");
	}

	if ([UIApplication sharedApplication].keyWindow.rootViewController == nil)
	{
		@throw(@"Error: There is currently no root view controller associated with the key window. \
			    Please initialize a library (e.g. opengl) that initializes a window, so the input library can attach to that.");
	}

	UIView *view = [UIApplication sharedApplication].keyWindow.rootViewController.view;

	DUELLGestureRecognizer *recognizer = [[DUELLGestureRecognizer alloc] initWithTarget:nil action:nil];
    [view addGestureRecognizer:recognizer];

    [recognizer initializeTouchCapturing];
}

@end
 

