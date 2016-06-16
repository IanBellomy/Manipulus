/**

	Cursor.x
	Cursor.y
	Cursor.pressed

	(should implement geom or something to work with Set)

*/

package net.manipulus
{	
	
	import flash.utils.*;
	import flash.events.*;
	import flash.display.*;
	
	public class Cursor extends Object
	{
		
		private static var _instance:Cursor;				
		
		protected static var _pressed:Boolean = false;
		protected static var _stage:Stage;
		
		public function Cursor()
		{
			super();
		}
		
		public static function init(stage:Stage):void
		{
			_stage = stage;
			_stage.addEventListener(MouseEvent.MOUSE_DOWN,handleMouseDown);
			_stage.addEventListener(MouseEvent.MOUSE_UP,handleMouseUp);
		}		
		
		public static function handleMouseDown(event:MouseEvent):void
		{
			_pressed = true;			
		}
		
		public static function handleMouseUp(event:MouseEvent):void
		{
			_pressed = false;
		}
		
		
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
	
		public static function get x():Number
		{
			if(_stage == null) return 0;
			return _stage.mouseX;
		}
		
		public static function get y():Number
		{
			if(_stage == null) return 0;
			return _stage.mouseY;
		}
	
		public static function get pressed():Boolean
		{
			if(_stage == null) return false;			
			return _pressed;
		}
		
		public static function valueOf()
		{
			return "Cursor";
		}
		
		public static function toString():String
		{
			return "Cursor";
		}
			
	}
}