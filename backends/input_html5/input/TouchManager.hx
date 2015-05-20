/*
 * Copyright (c) 2003-2015, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package input;

import msignal.Signal;

import de.polygonal.ds.pooling.DynamicObjectPool;

import js.JQuery;
import js.Browser;
import input.Touch;

class TouchManager
{
	public var onTouches (default, null) : Signal1<Array<Touch>>;
    private var touchPool: DynamicObjectPool<Touch>;
    private var touchesToSend : Array<Touch>;
    private var touchPoolSize : Int = 40;

	static private var touchInstance : TouchManager;

	private var jquery : JQuery;

	private function new()
	{
		jquery = new JQuery(Browser.window);
		onTouches = new Signal1();

        touchPool = new DynamicObjectPool<Touch>(Touch);
        touchesToSend = [];
	}

	static public function instance() : TouchManager
	{
		return touchInstance;
	}

	public static function initialize(finishedCallback : Void->Void) : Void
	{
		touchInstance  = new TouchManager();

		///same as $(function(){}) in javascript
		touchInstance.jquery.ready(function(e):Void {

			Browser.document.addEventListener('touchstart', function(e:Dynamic) {
				    e.preventDefault();
				    touchInstance.parseTouchObjects(e.touches, TouchState.TouchStateBegan);
			}, false);

			Browser.document.addEventListener('touchend', function(e:Dynamic) {
				    e.preventDefault();
				    touchInstance.parseTouchObjects(e.touches, TouchState.TouchStateEnded);

			}, false);

			Browser.document.addEventListener('touchmove', function(e:Dynamic) {
				    e.preventDefault();
				    touchInstance.parseTouchObjects(e.touches, TouchState.TouchStateMoved);
			}, false);

			Browser.document.addEventListener('touchcancel', function(e:Dynamic) {
				    e.preventDefault();
				    touchInstance.parseTouchObjects(e.touches, TouchState.TouchStateCancelled);

			}, false);

		});

		finishedCallback();
	}
	private function parseTouchObjects(touches:Array<Dynamic>, state:TouchState) : Void
	{
        if (touches.length > touchesToSend.length)
        {
            for (i in touchesToSend.length...touches.length)
            {
                touchesToSend.push(touchPool.get());
            }
        }
        else if (touches.length < touchesToSend.length)
        {
        	var unusedObjectsCount = touchesToSend.length - touches.length;
            var unusedObjects = touchesToSend.splice(touches.length, unusedObjectsCount);

            for(o in unusedObjects) touchPool.put(o);
        }

        for(i in 0...touches.length)
        {
            setupWithNativeTouch(touchesToSend[i], touches[i], state);
        }
		touchInstance.onTouches.dispatch(touchInstance.touchesToSend);

	}
	private function setupWithNativeTouch(touch : Touch, nativeTouchDynamic : Dynamic, state:TouchState):Void
	{
	    touch.x = nativeTouchDynamic.clientX;
	    touch.y = nativeTouchDynamic.clientY;
	    touch.id = nativeTouchDynamic.identifier;
	    touch.state = state;
	}
}
