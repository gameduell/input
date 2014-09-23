#import <input_ios/UIViewController+CaptureTouches.h>

#include <input_ios/NativeTouch.h>

#import <objc/runtime.h>

#define TOUCH_LIST_POOL_SIZE 40

static value touchListPool;
static value touchListToSend;

@implementation UIViewController (CaptureTouches)

- (void) initializeTouchCapturing
{
	touchListPool = alloc_array(TOUCH_LIST_POOL_SIZE);

    for (int i = 0; i < TOUCH_LIST_POOL_SIZE; i++)
    {
        val_array_set_i(touchListPool, i, input_ios::NativeTouch::createHaxePointer());
    }

    touchListToSend = alloc_array(TOUCH_LIST_POOL_SIZE);
}

- (void)capturedTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dispatchTouches:touches];
}

- (void)capturedTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dispatchTouches:touches];
}

- (void)capturedTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dispatchTouches:touches];
}

- (void)capturedTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dispatchTouches:touches];
}

int convertPointerToUniqueInt(void *ptr)
{
    int hash = 16777619; ////FNV PRIME, http://www.isthe.com/chongo/tech/comp/fnv/index.html#FNV-source
    hash ^= (long)ptr;

    return hash;
}

extern void callHaxeOnTouchesCallback(value touchList);
- (void) dispatchTouches:(NSSet *)touches
{
    NSUInteger touchCount = touches.count;

    val_array_set_size(touchListToSend, touchCount);

    int i = 0;
    for (UITouch *touch in touches)
    {
        value nativeTouchValue = val_array_i(touchListPool, i);
        val_array_set_i(touchListToSend, i, nativeTouchValue);

        input_ios::NativeTouch *nativeTouch = (input_ios::NativeTouch *)val_data(nativeTouchValue);
        CGPoint locationInView = [touch locationInView:self.view];
        nativeTouch->x = locationInView.x * [[UIScreen mainScreen] scale];
        nativeTouch->y = locationInView.y * [[UIScreen mainScreen] scale];

        switch(touch.phase)
        {
            case(UITouchPhaseBegan):
                nativeTouch->state = 0;
                break;
            case(UITouchPhaseMoved):
                nativeTouch->state = 1;
                break;
            case(UITouchPhaseStationary):
                nativeTouch->state = 2;
                break;
            case(UITouchPhaseEnded):
                nativeTouch->state = 3;
                break;
            case(UITouchPhaseCancelled):
                nativeTouch->state = 3;
        }
        nativeTouch->id = convertPointerToUniqueInt(touch);

        ++i;
    }

    callHaxeOnTouchesCallback(touchListToSend);
}


- (void)swizzleInstanceSelector:(SEL)originalSelector 
                withNewSelector:(SEL)newSelector
{
	Method originalMethod = class_getInstanceMethod([self class], originalSelector);
	Method newMethod = class_getInstanceMethod([self class], newSelector);

	BOOL methodAdded = class_addMethod([self class],
	                                 originalSelector,
	                                 method_getImplementation(newMethod),
	                                 method_getTypeEncoding(newMethod));

	if (methodAdded) {
		class_replaceMethod([self class], 
	  	                    newSelector, 
	   	                    method_getImplementation(originalMethod),
	    	                method_getTypeEncoding(originalMethod));
	} else {
		method_exchangeImplementations(originalMethod, newMethod);
	}
}

@end