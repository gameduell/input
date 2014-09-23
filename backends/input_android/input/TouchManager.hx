package input;

import input.Mouse;

import msignal.Signal;

import cpp.Lib;

import hxjni.JNI;

import input.Touch;

@:buildXml('
    <files id="haxe">
        <include name="${haxelib:input}/backends/input_android/native.xml" />
    </files>
')
@:headerCode("
    #include <input_android/NativeTouch.h>
    #include <input/Touch.h>
    #include <input/TouchState.h>
")
class TouchManager
{
	public var onTouches : Signal1<Array<Touch>>;

	static private var touchInstance : TouchManager;
	static private var inputandroid_initialize = Lib.load ("inputandroid", "inputandroid_initialize", 1);
    static private var j_initialize = JNI.createStaticMethod("org/haxe/duell/input/DuellInputActivityExtension", "initialize", "()V");

    private var touchPool : Array<Touch>;
    private var touchesToSend : Array<Touch>;
    private static inline var touchPoolSize : Int = 40; /// well, doesn't cost anything

	private function new()
	{
		onTouches = new Signal1();

        touchPool = [];
        for(i in 0...touchPoolSize)
        {
            touchPool.push(new Touch());
        }
        touchesToSend = [];

        inputandroid_initialize(
            newTouchesCallback
        );

        j_initialize();
	}

	public function newTouchesCallback(touches : Array<Dynamic>)
    {
        if (touches.length > touchesToSend.length)
        {
            for (i in touchesToSend.length...touches.length)
            {
                touchesToSend.push(touchPool[i]);
            }
        }
        else if (touches.length < touchesToSend.length)
        {
            touchesToSend.splice(touches.length, touchesToSend.length - touches.length);
        }

        for(i in 0...touches.length)
        {
            setupWithNativeTouch(touchesToSend[i], touches[i]);

        }

        onTouches.dispatch(touchesToSend);
    }

    @:functionCode("
        input_android::NativeTouch *nativeTouch = (input_android::NativeTouch *)nativeTouchDynamic->__GetHandle();
        touch->x = nativeTouch->x;
        touch->y = nativeTouch->y;
        touch->id = nativeTouch->id;

        switch(nativeTouch->state) {
            case (int)0: {
                touch->state = ::input::TouchState_obj::TouchStateBegan;
            }
            ;break;
            case (int)1: {
                touch->state = ::input::TouchState_obj::TouchStateMoved;
            }
            ;break;
            case (int)2: {
                touch->state = ::input::TouchState_obj::TouchStateStationary;
            }
            ;break;
            case (int)3: {
                touch->state = ::input::TouchState_obj::TouchStateEnded;
            }
            ;break;
        }
    ") 
    private static function setupWithNativeTouch(touch : Touch, nativeTouchDynamic : Dynamic) : Void {}

	static public inline function instance() : TouchManager
	{
		return touchInstance;
	}

	public static function initialize(finishedCallback : Void->Void) : Void
	{
		touchInstance = new TouchManager();

		finishedCallback();
	}


}
