#include <input_ios/NativeTouch.h>
#include <string>

#include <hx/CFFI.h>

class NativeTouch_Impl : public input_ios::NativeTouch
{
	public:
		static value createHaxePointer();

		~NativeTouch_Impl();
		NativeTouch_Impl();

		int get_x();
};

NativeTouch_Impl::NativeTouch_Impl()
{
	x = 0;
	y = 0;
	id = 0;
	state = 0;
	timestamp = false;
}

NativeTouch_Impl::~NativeTouch_Impl()
{

}

DEFINE_KIND(k_NativeTouch) 

value input_ios::NativeTouch::createHaxePointer()
{
	value v;
	v = alloc_abstract(k_NativeTouch, new NativeTouch_Impl());
	return v;
}


