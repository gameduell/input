#ifndef __INPUT_ANDROID_NATIVE_TOUCH__
#define __INPUT_ANDROID_NATIVE_TOUCH__


class NativeTouch
{
	public: 
		int x;
		int y;
		int id;
		int state; ///0 began, 1 moved, 2 stationary, 3 ended, 4 cancelled
		NativeTouch();
		~NativeTouch();
};


#endif //__INPUT_ANDROID_NATIVE_TOUCH__