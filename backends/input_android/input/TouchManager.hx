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
@:headerClassCode('                 
public:                             
    int _touchCountForBatch;     
    int _currentTouchIndex;  
') 
class TouchManager
{
	public var onTouches : Signal1<Array<Touch>>;

	static private var touchInstance : TouchManager;
	static private var inputandroid_initialize = Lib.load ("inputandroid", "inputandroid_initialize", 2);
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
            touchBatchStartingCallback,
            touchCallback
        );

        j_initialize();
	}

    @:functionCode("
        _touchCountForBatch = *(int*)touchCountValue->__GetHandle();
        _currentTouchIndex = 0;

        int touchCount = _touchCountForBatch;

        if(touchCount > this->touchesToSend->length)
        {
            int i = this->touchesToSend->length;
            while(this->touchesToSend->length < touchCount)
            {
                this->touchesToSend->push(this->touchPool->__get(i).StaticCast< ::input::Touch >());
                i++;
            }
        }
        else
        {
            if (touchCount < this->touchesToSend->length)
            {
                this->touchesToSend->splice(touchCount,(this->touchesToSend->length - touchCount,true));
            }
        }
    ") 
    private function touchBatchStartingCallback(touchCountValue : Dynamic) {}

    @:functionCode("
        ::input::Touch touch = this->touchesToSend->__get(_currentTouchIndex).StaticCast< ::input::Touch >();

        NativeTouch *nativeTouch = (NativeTouch*)touchValue->__GetHandle();

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
            case (int)4: {
                touch->state = ::input::TouchState_obj::TouchStateCancelled;
            }
            ;break;
        }


        _currentTouchIndex++;

        if (_touchCountForBatch == _currentTouchIndex)
        {
            this->onTouches->dispatch(this->touchesToSend);

        }
    ") 
    private function touchCallback(touchValue : Dynamic) {}

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
