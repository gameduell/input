#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
 
@interface UIViewController (CaptureTouches)

 
- (void)initializeTouchCapturing;
- (void)capturedTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)capturedTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)capturedTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)capturedTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)swizzleInstanceSelector:(SEL)originalSelector 
                withNewSelector:(SEL)newSelector;

@end