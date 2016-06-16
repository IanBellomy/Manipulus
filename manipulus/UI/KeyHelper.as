/*

	Singleton 
	
		NewEvents
	
			KEY_TAP
			KEY_DOUBLETAP
			KEY_HOLD
			KEY_COMBO	
				addEventListener('keyCombo',handler,[key1,key2],..so on)
			

*/

package net.manipulus.UI
{	

	import flash.events.*;
	import flash.display.*;
	import flash.utils.*;
		
	public class KeyHelper extends EventDispatcher
	{
		
		//---------------------------------------
		// Static variables
		//---------------------------------------
		//public static const KEY_DOWN : String = 'keyDown';
		//public static const KEY_UP : String = 'keyUp';
		public static const KEY_REPEAT : String 	= 'keyRepeat';	
		public static const KEY_TAP		: String	= 'KEY_TAP';
		
		public static const TAP_TIME	: int	= 200;
		
		private static var _instance : KeyHelper;
		
		//---------------------------------------
		// Private Variables
		//---------------------------------------
		protected var _pressedKeys 		: Array;
		protected var _pressedTimes 	: Dictionary;
		protected var _releasedTimes 	: Dictionary;

		// Constructor
		public function KeyHelper()
		{
			_pressedKeys = [];
			_pressedTimes = new Dictionary();
			_releasedTimes = new Dictionary();
		}
		
		//---------------------------------------
		// Static Event handlers
		//---------------------------------------
		public static function init(stage_:Stage):void
		{
			if(_instance == null)
			{
				_instance = new KeyHelper();
				stage_.addEventListener(KeyboardEvent.KEY_DOWN,KeyHelper.handleKeyDown);
				stage_.addEventListener(KeyboardEvent.KEY_UP,KeyHelper.handleKeyUp);
				return;
			}
			trace('WARNING: Multiple calls to KeyHelper.init are ignored.');
		}
		
		public static function handleKeyDown(e:KeyboardEvent):void
		{
			if(_instance._pressedKeys.indexOf(e.keyCode) == -1)
			{
				_instance._pressedKeys.push(e.keyCode);
				
				var pressedTime : int = new Date().getTime();								
				_instance._pressedTimes[e.keyCode] = pressedTime;

				_instance.dispatchEvent(e);
				
				
			}
			else
			{
				_instance.dispatchEvent( new Event(KeyHelper.KEY_REPEAT));
			}

		}
		
		public static function handleKeyUp(e:KeyboardEvent):void
		{
			var keyIndex : int = _instance._pressedKeys.indexOf(e.keyCode);
			if( keyIndex!=-1)
			{
				_instance._pressedKeys.splice(keyIndex,1);

				var releasedTime : int = new Date().getTime();
									
				if( releasedTime - _instance._pressedTimes[e.keyCode] <= TAP_TIME )
				{
					var newEvent : KeyboardEvent = new KeyboardEvent('KEY_TAP', true, false, e.charCode,e.keyCode,e.keyLocation, e.ctrlKey, e.altKey, e.shiftKey);
					_instance.dispatchEvent(newEvent);					
					trace('tap');
				} 
				else _instance.dispatchEvent(e);
				
				_instance._releasedTimes[e.keyCode] = releasedTime;
			}
		}
		
		//---------------------------------------
		// Wrapper		
		//---------------------------------------
		
		public static function addEventListener(...arg)
		{
			return _instance.addEventListener.apply(_instance,arg);
		}
		
		public static function removeEventListener(...arg)
		{
			return _instance.addEventListener.apply(_instance,arg);
		}
		
		//---------------------------------------
		// Static Functions
		//---------------------------------------
		public static function isDown(charCode):Boolean
		{
			return _instance._pressedKeys.indexOf(charCode) > -1;
		}
		
		//---------------------------------------
		// Static Getter Setters
		//---------------------------------------
		public function get instance()
		{
			if(_instance == null)
			{
				trace('ERROR: KeyboardHelper.init() must first be called')
			}
			return _instance
		}
		
		
	}
}