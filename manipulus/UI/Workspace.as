/*

	Helpful properties
	
		mouseDown : Boolean (Read Only)
		pMouseX	: Number (Read Only)
		pMouseY : Number
				
		mouseX		// readable and writeable, so the workspace can be de-coupled from the mouse...	
		mouseY

	function
	
		isKeyDown(keyCharacter:String) : Boolean	// phrase as property?

	replaceable functions, scoped to _scope... kinda dumb...
				
		draw
		handleDown
		handleUp
		handleEnterFrame
		

*/

package net.manipulus.ui
{

	import flash.display.*;
	import flash.events.*;

	public class Workspace extends Sprite
	{
	
		private var _scope		: DisplayObject;
		private var _stage 		: Stage;
		private var _pMouseX 	: Number;
		private var _pMouseY 	: Number;
		private var _mouseDown 	: Boolean = false;

		public var draw 			: Function;
		public var handleMouseDown 	: Function;
		public var handleMouseUp	: Function;

		public var mouseX 		: int = 0;
		public var mouseY 		: int = 0;				
		
		public var backgroundLayer : Sprite;
		public var foregroundLayer : Sprite;
		
		public function Workspace(scope_:DisplayObject)
		{
			backgroundLayer = new Sprite();
			foregroundLayer = new Sprite();
			addChild(backgroundLayer);
			addChild(foregroundLayer);
			
			backgroundLayer.graphics.beginFill(0xffffff);
			backgroundLayer.graphics.drawRect(0,0,500,500);
			backgroundLayer.graphics.endFill();
			
			_scope = this;
		}
		
		public function init()
		{
//			Binder.mapAbs(stage,'mouseX',this,'mouseX');
//			Binder.mapAbs(stage,'mouseY',this,'mouseY');
			
			_pMouseX = mouseX;
			_pMouseY = mouseY;
						
			_scope.stage.addEventListener(Event.ENTER_FRAME,_handleEnterFrame);
			_scope.stage.addEventListener(MouseEvent.MOUSE_DOWN,_handleMouseDown);
			_scope.stage.addEventListener(MouseEvent.MOUSE_UP,_handleMouseUp);
			
		}
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		public function addBox(x,y,clr):void
		{
			
		}
		
		// blerck, yurk, yuck
		public function bindChanges(o1,p1,o2,p2):Relationship
		{
			return Binder.bindChanges(o1,p1,o2,p2);
		}		
		
		
		//---------------------------------------
		// EVENT HANDLERS
		//---------------------------------------
		
		private function _handleEnterFrame(e:Event):void
		{	
			if(draw != null) draw.apply(_scope);
			
			_pMouseX = mouseX;
			_pMouseY = mouseY;
			
		}
		
		private function _handleMouseDown(e:MouseEvent):void
		{
			_mouseDown = true;
			if(handleMouseDown != null) handleMouseDown.apply(_scope);
		}
		
		private function _handleMouseUp(e:MouseEvent):void
		{
			_mouseDown = false;
			if(handleMouseUp != null) handleMouseUp.apply(_scope);
		}
		
		public function isKeyDown(key:String)
		{
			return false;
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		public function get mouseDown():Boolean
		{
			return _mouseDown;
		}

		public function get pMouseX():int
		{
			return _pMouseX
		}

		public function get pMouseY():int
		{
			return _pMouseY
		}

		public function set mouseDown(n:Boolean):void
		{
			trace('mouseDown is read only; You may not assign a value to it.');
		}

		public function set pMouseX(n:int):void
		{
			trace('pMouseX is read only; You may not assign a value to it.');
		}

		public function set pMouseY(n:int):void
		{
			trace('pMouseY is read only; You may not assign a value to it.');
		}
		
		/*
		public function get mouseX():Number
		{
			return _;
		}
		
		public function get mouseY():Number
		{
			return mouse.y;
		}
		*/		
		
	
	}

}

