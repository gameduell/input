package input;

import input.Mouse;

import msignal.Signal;

import de.polygonal.ds.pooling.DynamicObjectPool;

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
	static private var inputios_initialize = Lib.load ("inputios", "inputios_initialize", 2);

    private var touchPool: DynamicObjectPool<Touch>;
    private var touchesToSend : Array<Touch>;
    private static inline var touchPoolSize : Int = 40; /// well, doesn't cost anything

    /// prevents GC in release
    private var __touchListCache: Dynamic;
    private var __touchCountCache: Dynamic;

	private function new()
	{
		onTouches = new Signal1();

        touchPool = new DynamicObjectPool<Touch>(Touch);

        touchesToSend = [];

        inputios_initialize(
            newTouchesCallback,
            setCachedVariables
        );
	}

    private function setCachedVariables(touchListCache: Dynamic, touchCountCache: Dynamic)
    {
        __touchListCache = touchListCache;
        __touchCountCache = touchCountCache;
    }

    @:functionCode("
        int _touchCount = *(int*)touchCount->__GetHandle();
        NativeTouch *_touchList = (NativeTouch*)touchList->__GetHandle();
        if(_touchCount > this->touchesToSend->length)
        {
            int i = this->touchesToSend->length;
            while(this->touchesToSend->length < _touchCount)
            {
                this->touchesToSend->push(this->touchPool->get().StaticCast< ::input::Touch >());
                i++;
            }
        }
        else if (_touchCount < this->touchesToSend->length)
        {
            int unusedObjectsCount = (this->touchesToSend->length - _touchCount);
            Array< ::Dynamic> unusedObjects = this->touchesToSend->splice(_touchCount, unusedObjectsCount);
            for(int i = 0; i < unusedObjects->length; ++i)
            {
                ::input::Touch o = unusedObjects->__get(i).StaticCast< ::input::Touch >();
                ::de::polygonal::ds::pooling::DynamicObjectPool _this = this->touchPool;
                int _g1 = (_this->_top)++;
                hx::IndexRef((_this->_pool).mPtr,_g1) = o;
                (_this->_used)--;
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
