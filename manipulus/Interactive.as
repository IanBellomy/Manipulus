/*

	Wrapper to add "touched" and "pressed" properties.
	
	// this could really be done with something like: 
		new Set(clip,mouse).overlap

	// other potential handy properties
	
		.playing
		.currentFrame
		
		.left
		.right
		.top
		.bottom  (don't know where origin is though...)
		
		// need to check for suspend...

	aka. "An Interactive", interactive being a noun for something that is 'interactive', something that has proper

	...might be better for it to be an AbstractManipulable (and have a interface Manipulable)

*/

package net.manipulus
{	
	
	import flash.display.*;
	import flash.events.*;
	
	public class Interactive extends Object
	{
	
		private var _following:DisplayObject;
		private var _touched:Boolean = false;	// should these be false? What if it is pressed?
		private var _pressed:Boolean = false;
		
		public function Interactive(displayObject:DisplayObject)
		{
			super();
			_following = displayObject;
			_following.addEventListener(MouseEvent.ROLL_OVER,handleOver);
			_following.addEventListener(MouseEvent.ROLL_OUT,handleOut);			
			_following.addEventListener(MouseEvent.MOUSE_DOWN,handleDown);

			if(_following.stage) _following.stage.addEventListener(MouseEvent.MOUSE_UP,handleUp);			
			
			_following.stage.addEventListener(Event.ADDED,handleAdded);
			_following.stage.addEventListener(Event.REMOVED,handleRemoved);
		}
		
		public function isFollowing(obj:DisplayObject):Boolean
		{
			return _following == obj;
		}
		
		public function kill():void
		{
			trace("Interactive::kill()");
			_following.removeEventListener(MouseEvent.ROLL_OVER,handleOver);
			_following.removeEventListener(MouseEvent.ROLL_OUT,handleOut);			
			_following.removeEventListener(MouseEvent.MOUSE_DOWN,handleDown);
			_following.stage.addEventListener(Event.ADDED,handleAdded);					
			_following.stage.addEventListener(Event.REMOVED,handleRemoved);
		}
		
		//---------------------------------------
		// EVENT HANDLERS
		//---------------------------------------
		public function handleAdded(event:Event):void
		{
			_following.stage.addEventListener(MouseEvent.MOUSE_UP,handleUp);			
		}
		
		public function handleRemoved(event:Event):void
		{
			return;
			//trace("Interactive::handleRemoved()",this);
			_pressed = false;
			_following.stage.removeEventListener(MouseEvent.MOUSE_UP,handleUp);
		}		

		public function handleOut(event:MouseEvent):void
		{
			_touched = false;
		}
		
		public function handleUp(event:MouseEvent):void
		{
			//trace("Interactive::handleUp() ",this);
			_pressed = false;
		}
		
		public function handleDown(event:MouseEvent):void
		{			
			//trace("Interactive::handleDown()", this);
			_pressed = true;
		}
		
		public function handleOver(event:MouseEvent):void
		{
			_touched = true;
		}
		
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		public function get touched():Boolean
		{
			return _touched;
		}
		
		public function get pressed():Boolean
		{
//			trace("Interactive::get pressed()",_pressed);
			return _pressed;
		}
		
		public function set touched(value:Boolean):void
		{
			trace("Interactive::set touched():: WARNING :: property	'touched' is read only.");
			//_touched = value;
		}
		
		public function set pressed(value:Boolean):void
		{
			trace("Interactive::set pressed():: WARNING :: property 'pressed' is read only.");
			//_pressed = value;
		}
		
		public function get following():DisplayObject
		{
			return _following;
		}
		
		public function get name():String
		{
			return _following.name;
		}
		
		public function toString():String
		{
			return _following.name;//+"(i)";
		}
	}
}