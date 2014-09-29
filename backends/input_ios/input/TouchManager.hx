package input;

import input.Mouse;

import msignal.Signal;

import cpp.Lib;

import input.Touch;

@:buildXml('
    <files id="haxe">
        <include name="${haxelib:input}/backends/input_ios/native.xml" />
    </files>
')
@:headerCode("
    #include <input_ios/NativeTouch.h>
    #include <input/Touch.h>
    #include <input/TouchState.h>
")
class TouchManager
{
	public var onTouches : Signal1<Array<Touch>>;

	static private var touchInstance : TouchManager;
	static private var inputios_initialize = Lib.load ("inputios", "inputios_initialize", 1);

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

        inputios_initialize(
            newTouchesCallback
        );
	}

    @:functionCode("
        NativeTouch *_touchList = (NativeTouch*)touchList->__GetHandle();
        int _touchCount = *(int*)touchCount->__GetHandle();
        if(_touchCount > this->touchesToSend->length)
        {
            int i = this->touchesToSend->length;
            while(this->touchesToSend->length < _touchCount)
            {
                this->touchesToSend->push(this->touchPool->__get(i).StaticCast< ::input::Touch >());
                i++;
            }
        }
        else
        {
            if (_touchCount < this->touchesToSend->length)
            {
                this->touchesToSend->splice(_touchCount,(this->touchesToSend->length - _touchCount,true));
            }
        }

        int i = 0;
        while(i < _touchCount)
        {
            ::input::Touch touch = this->touchesToSend->__get(i).StaticCast< ::input::Touch >();

            touch->x = _touchList[i].x;
            touch->y = _touchList[i].y;
            touch->id = _touchList[i].id;

            switch(_touchList[i].state) {
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


            i++;
        }
        this->onTouches->dispatch(this->touchesToSend);
    ") 
	public function newTouchesCallback(touchCount : Dynamic, touchList : Dynamic) {}

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
