/*

	OUT OF DATE: 8.15.11

	Abstract Button that has drag and drop functionality...

	Should send DragDropEvents

		Needs a clip called "draggableClip"

		EVENTS:

			DragDropEvent.GRAB
			DragDropEvent.DROP (can be intercepted to trigger alternate behavior)
						

		Animation Methods
		
			animateOver
			animateOut
			animateDragFrom		// click and drag out
			animateDragBack		// click and drag out and back in
			animateGrab
			animateDrop	
			
			animatePlace(target)			// depricated; up to parent view and target
			animateDraggedOver(target)		// depricated; up to parent view and target
			animateDraggedOut(formerTarget) // depricated; up to parent view and target
			animateRefresh()				// depricated; refresh up to parent view
			
		// shouldn't receive a roll out when we release...

	
*/

package net.manipulus.UI
{	
	
	import flash.events.*;
	import flash.display.*;
	import flash.utils.*;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	
	public class DragButton extends Sprite
	{

//		public var draggableClip : MovieClip;

//		protected var _hitClip : Sprite;		
		protected var _pressed 	 : Boolean = false;
		protected var _hovered 	 : Boolean = false;
		public var _dragEase  : int	 	= 3; 

 		private var dragHomeX : Number = 0;
 		private var dragHomeY : Number = 0;		

		public function DragButton()
		{
			super();
			buttonMode = true;
			mouseChildren = false;
			//trace("DragButton::DragButton()");
			if(stage!=null) init();
		}
		
		public function init():void
		{
			addEventListener(MouseEvent.ROLL_OVER,handleOver);
			addEventListener(MouseEvent.ROLL_OUT,handleOut);
			addEventListener(MouseEvent.MOUSE_DOWN,handleDown);
			stage.addEventListener(MouseEvent.MOUSE_UP,handleUp);
			
			addEventListener(DragDropEvent.GRAB,handleGrab);
			addEventListener(DragDropEvent.DROP,handleDrop);			
//			stage.addEventListener(Event.ENTER_FRAME,handleEnterFrame);	// depricated
			
//			dragHomeX = draggableClip.x;
//			dragHomeY = draggableClip.y;			
		}
		
		
		//---------------------------------------
		// PUBLIC ANIMATION METHODS TO OVERRIDE
		//---------------------------------------
		
		// roll over
		public function animateOver(e:Event=null):void
		{
			//trace("DragButton::animateOver()");
		}
		
		// rollout
		public function animateOut(e:Event=null):void
		{
			//trace("DragButton::animateOut()");
		}
		
		// when source content is dragged out
		public function animateDragFrom(e:Event=null):void
		{
			//trace("DragButton::animateDragFrom()");
			alpha = .25;			
		}
		
		// when source content is dragged back
		public function animateDragBack(e:Event=null):void
		{
			//trace("DragButton::animateDragBack()");
			alpha = .5;
		}
		
		// when button is pressed
		public function animateGrab(e:Event=null):void
		{
			//trace("DragButton::animateGrab()");
			alpha = .5;
		}
		
		// default animation for a drop / also when released on 'nothing', or nothing that accepts the input.
		public function animateDrop(e:Event=null):void
		{
			//trace("DragButton::animateDrop()");
			_dragEase = 3;
			alpha = 1;
//			TweenLite.to(draggableClip,.45,{x:dragHomeX,y:dragHomeY,ease:Elastic.easeOut});
		}
		
		// when released on a viable target something
		public function animatePlace(targetItem:* = null):void
		{
			// clip dropped on something
			//trace("DragButton::animatePlace()");
			_dragEase = 3;
//			TweenLite.to(draggableClip,.25,{alpha:0});
//			TweenLite.to(draggableClip,0,{delay:.25,x:0,y:0,overwrite:false});
//			TweenLite.to(draggableClip,.25,{delay:.5,alpha:1,overwrite:false});
			
			mouseEnabled 	= false;
			mouseChildren 	= false;
			setTimeout(function(clip){clip.mouseEnabled = true;},.75,this);
		}
		
		// when the draggable clip is dragged over a viable target
		public function animateDraggedOver(target:iDropTarget=null):void
		{
			//trace("DragButton::animateDragOver()");
		}

		// when the draggable clip is dragged out from a viable target
		public function animateDraggedOut(formerTarget:iDropTarget=null):void
		{
			//trace("DragButton::animateDraggedOut()");
		}
		
		// depricated
		/*
		public function animateRefresh(e:Event=null):void
		{
			if(_pressed)
			{
//				trace((Math.abs(draggableClip.parent.mouseX-draggableClip.x) + Math.abs(draggableClip.parent.mouseY-draggableClip.y)));
				if((Math.abs(draggableClip.parent.mouseX-draggableClip.x) + Math.abs(draggableClip.parent.mouseY-draggableClip.y)) <=.25 ) _dragEase = 1;
				
				draggableClip.x += ((draggableClip.parent.mouseX)-draggableClip.x)/_dragEase;
				draggableClip.y += ((draggableClip.parent.mouseY)-draggableClip.y)/_dragEase;
			}
		}*/
		
		//---------------------------------------
		// EVENT HANDLERS
		//---------------------------------------
		
		public function handleOver(e:MouseEvent):void
		{
			if(_pressed) animateDragBack();			
			else animateOver();
		}
		
		public function handleOut(e:MouseEvent = null):void
		{
			if(_pressed) animateDragFrom();
			else animateOut();			
		}
		
		public function handleDown(e:MouseEvent):void
		{
			_pressed = true;
			dispatchEvent(new DragDropEvent(DragDropEvent.GRAB,true));
			animateGrab();	// maybe should listen and do somthing?
		}

		public function handleUp(e:MouseEvent):void
		{
			if(!_pressed) return;
			_pressed = false;			
			dispatchEvent(new DragDropEvent(DragDropEvent.DROP,true)); // dispatch different event if dropped inside?...
		}
		
		public function handleDrop(e:DragDropEvent):void
		{
			animateDrop();
		}
		
		public function handleGrab(e:DragDropEvent):void
		{
			animateGrab();
		}
		
		// depricated
/*		public function handleEnterFrame(e:Event):void
		{
			animateRefresh();
		}*/
		
		public function getDraggableContentRepresentation():DisplayObject
		{
			var bmp = new Bitmap();
			bmp.bitmapData = new BitmapData(width,height,true,0x00000000);
			bmp.bitmapData.draw(this);
			return bmp;
		}

	}
}