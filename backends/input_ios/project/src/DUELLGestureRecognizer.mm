#import <input_ios/DUELLGestureRecognizer.h>

#include <input_ios/NativeTouch.h>

#import <objc/runtime.h>

#include <hx/CFFI.h>

#define TOUCH_LIST_POOL_SIZE 40

static NativeTouch *touchList = NULL;
static int touchCount;

DEFINE_KIND(k_TouchCount) 
DEFINE_KIND(k_TouchList) 

static value touchCountValue;
static value touchListValue;

@implementation DUELLGestureRecognizer

extern void callSetCachedVariablesCallback(value touchCount, value touchList);
- (void) initializeTouchCapturing
{
    NSLog(NSStringFromClass([self class]));

    touchList = new NativeTouch[TOUCH_LIST_POOL_SIZE];

    touchCountValue = alloc_abstract(k_TouchCount, &touchCount);
    touchListValue = alloc_abstract(k_TouchList, touchList);

    callSetCachedVariablesCallback(touchCountValue, touchListValue);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dispatchTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dispatchTouches:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dispatchTouches:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
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

    NSLog(@"%@", touches);

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

- (void) dealloc
{
    delete[] touchList;

    [super dealloc];
}

@end