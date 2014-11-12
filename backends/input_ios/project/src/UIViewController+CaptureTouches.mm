#import <input_ios/UIViewController+CaptureTouches.h>

#include <input_ios/NativeTouch.h>

#import <objc/runtime.h>

#include <hx/CFFI.h>

#define TOUCH_LIST_POOL_SIZE 40

static NativeTouch *touchList;
static int touchCount;

DEFINE_KIND(k_TouchCount) 
DEFINE_KIND(k_TouchList) 

static value touchCountValue;
static value touchListValue;

@implementation UIViewController (CaptureTouches)

extern void callSetCachedVariablesCallback(value touchCount, value touchList);
- (void) initializeTouchCapturing
{
    touchList = new NativeTouch[TOUCH_LIST_POOL_SIZE];

    touchCountValue = alloc_abstract(k_TouchCount, &touchCount);
    touchListValue = alloc_abstract(k_TouchList, touchList);

    callSetCachedVariablesCallback(touchCountValue, touchListValue);
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

extern void callHaxeOnTouchesCallback(value touchCount, value touchList);
- (void) dispatchTouches:(NSSet *)touches
{
    touchCount = touches.count;

    int i = 0;
    for (UITouch *touch in touches)
    {
        CGPoint locationInView = [touch locationInView:self.view];
        touchList[i].x = locationInView.x * [[UIScreen mainScreen] scale];
        touchList[i].y = locationInView.y * [[UIScreen mainScreen] scale];

        switch(touch.phase)
        {
            case(UITouchPhaseBegan):
                touchList[i].state = 0;
                break;
            case(UITouchPhaseMoved):
                touchList[i].state = 1;
                break;
            case(UITouchPhaseStationary):
                touchList[i].state = 2;
                break;
            case(UITouchPhaseEnded):
                touchList[i].state = 3;
                break;
            case(UITouchPhaseCancelled):
                touchList[i].state = 4;
        }
        touchList[i].id = convertPointerToUniqueInt(touch);

        ++i;
    }

    callHaxeOnTouchesCallback(touchCountValue, touchListValue);
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

- (void) dealloc
{
    delete[] touchList;

    [super dealloc];
}

@end