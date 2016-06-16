package net.manipulus.UI
{	

	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.geom.*;

	import com.greensock.*;
	import com.greensock.easing.*;

	dynamic public class ElementButton extends Sprite
	{

		public var draggableClip : Sprite;

		
		private var _pressed : Boolean = false;
		private var _hovered : Boolean = false;		

		
		// type of box? (color)
		// type of element?		

		public function ElementButton()
		{
			super();			
			buttonMode = true;
			draggableClip.alpha = .25;
			/*draggableClip = new Sprite();
			addChild(draggableClip);			*/
			init();
			//trace("ElementButton::ElementButton()");
		}

		public function init():void
		{			
			addEventListener(MouseEvent.ROLL_OVER,over);
			addEventListener(MouseEvent.ROLL_OUT,out);
			addEventListener(MouseEvent.MOUSE_DOWN,down);
			stage.addEventListener(MouseEvent.MOUSE_UP,up);
			stage.addEventListener(Event.ENTER_FRAME,handleEnterFrame);	
			
			var pp:PerspectiveProjection=new PerspectiveProjection();
			pp.projectionCenter = globalToLocal(new Point(stage.stageWidth/2,stage.stageHeight/2));
			transform.perspectiveProjection = pp;
		}

		//---------------------------------------
		// EVENT HANDLERS
		//---------------------------------------
		
		public function over(e:MouseEvent):void
		{
			if(_pressed) return;
						
			TweenMax.to(draggableClip,.25,{alpha:1,z:-10,x:-5,y:-5,
					dropShadowFilter:{alpha:.75, angle:45, blurX:8, blurY:8, color:0, distance:4, quality:3}
					});
			TweenLite.to(plusClip,.25,{alpha:0});
			
			// should animate what to do... 
			dispatchEvent(new Event('NewElementHover',true));
		}
		
		public function out(e:MouseEvent = null):void
		{
			// was released? is resetting?
			if(_pressed) return;
			TweenLite.to(draggableClip,.25,{alpha:.25,z:0,x:0,y:0,
					dropShadowFilter:{alpha:0, angle:45, blurX:1, blurY:1, color:0, distance:0, quality:3}
					});
			TweenLite.to(plusClip,.25,{alpha:1});
		}
		
		public function down(e:MouseEvent):void
		{
			dispatchEvent(new Event('NewBoxDown',true));
			_pressed = true;
			
			TweenLite.to(plusClip,.25,{alpha:0});
			TweenLite.to(draggableClip,.25,{alpha:.75});
			// _pressed animation
			// make box draggable...
		}

		public function up(e:MouseEvent):void
		{
			if(!_pressed) return;
			
			dispatchEvent(new Event('NewElementReleased',true));

			return;
			//contains(e.target as DisplayObject)
			if(true)
			{

				// wheredid we release? Generic event? :: dispatchEvent(new Event('NewBoxRelease',true));
				// if in the workspace... :: dispatchEvent(new Event('NewBoxPlaced',true)); ?
					// add to works space, replace box animation.
				// else dispatchEvent(new Event('NewBoxDropped',true)); ? 
					// return box to home.

				// run out handler
//				handleElementDropped();
				handleElementPlaced();
			}
		}
		
		public function handleEnterFrame(e:Event):void
		{
			
			graphics.clear();
			
			if(_pressed)
			{
				draggableClip.x += ((mouseX - draggableClip.width/2)-draggableClip.x)/3;
				draggableClip.y += ((mouseY - draggableClip.height/2)-draggableClip.y)/3;
				

				graphics.lineStyle(1,0,.25);
				graphics.drawRect(draggableClip.x,draggableClip.y,50,50);
				
			}
			/*
			if(_hovered)
			{
				
			}
			*/
		}
		
		//---------------------------------------
		// INTERNAL EVENT HANDLERS
		//---------------------------------------
		
		public function handleReturnAnimationComplete():void
		{
			_pressed = false;
			out();
		}		

		public function handleElementPlaced():void
		{				
			// return element
			TweenLite.to(draggableClip,.5,{alpha:0,z:0,dropShadowFilter:{alpha:0, angle:45, blurX:1, blurY:1, color:0, distance:0, quality:3}});
			
			setTimeout(function(){
				plusClip.alpha		 =.5;			
				draggableClip.alpha  = 0;
				draggableClip.z 	 = 4;
				draggableClip.y 	 = 1;
				draggableClip.x 	 = 1;
			},500);
			
			TweenLite.to(draggableClip,.25,{alpha:1,delay:1});
			
			_pressed = false;
		}
		
		// release of element somplace illegal
		public function handleElementDropped():void
		{
			TweenLite.to(draggableClip,.75,{/*alpha:.5,*/z:0,x:0,y:0,ease:Elastic.easeOut,onComplete:handleReturnAnimationComplete});			
			TweenLite.to(plusClip,.25,{alpha:.5,delay:.5});
		}

	}
}