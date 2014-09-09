#import <input_ios/InputCapturer.h>

#import <input_ios/UIViewController+CaptureTouches.h>



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

	[[UIApplication sharedApplication].keyWindow.rootViewController 
		initializeTouchCapturing];
	[[UIApplication sharedApplication].keyWindow.rootViewController 
				swizzleInstanceSelector:@selector(touchesBegan:withEvent:)
		        withNewSelector:@selector(capturedTouchesBegan:withEvent:)];

	[[UIApplication sharedApplication].keyWindow.rootViewController 
				swizzleInstanceSelector:@selector(touchesMoved:withEvent:)
		        withNewSelector:@selector(capturedTouchesMoved:withEvent:)];

	[[UIApplication sharedApplication].keyWindow.rootViewController 
				swizzleInstanceSelector:@selector(touchesEnded:withEvent:)
		        withNewSelector:@selector(capturedTouchesEnded:withEvent:)];

	[[UIApplication sharedApplication].keyWindow.rootViewController 
				swizzleInstanceSelector:@selector(touchesCancelled:withEvent:)
		        withNewSelector:@selector(capturedTouchesCancelled:withEvent:)];


}

@end
 

