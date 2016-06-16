/*

	ElementTokens are ui elements that refer to an element

*/

package net.manipulus.UI
{	

	import com.greensock.*;
	import com.greensock.easing.*;	
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.*;
	import flash.events.*;

	import net.manipulus.*;

	public class ElementToken extends Sprite
	{

		public var targetElement : Object;
		public var active : Boolean = false;
		public var shape : Sprite;
		
		public function ElementToken(targetElement_:Object,isSelected:Boolean)
		{								
			super();
			
			if(targetElement_ is Sprite)
			{
				scaleX           = scaleY = 0;
				targetElement    = targetElement_;			
				x                = targetElement.x;
				y                = targetElement.y;
			}
			
			var clr	 		 = (isSelected)? 0x6A838E : targetElement.color;
			
			shape            = new Sprite();			
			shape.buttonMode = true;		
			shape.mouseEnabled = false;
			shape.graphics.lineStyle(3,0x6A838E);
			shape.graphics.beginFill(clr);
			shape.graphics.drawCircle(0,0,10);
			shape.graphics.endFill();
			
			shape.addEventListener(MouseEvent.ROLL_OVER,handleOver);
									
			addChild(shape);

			filters = [new DropShadowFilter(4,85,0x000000,.5,10,10)];

		}
				

		public function reveal():void
		{
			active = true;
			shape.mouseEnabled = true;
			TweenLite.to(this,.75,{	scaleX:1,
									scaleY:1,
									ease:Elastic.easeOut,
									onComplete:dispatchEvent,
									onCompleteParams:[new Event('elementTokenReveal',true)]});

		}
		
		public function hide():void
		{
//			trace("ElementToken::hide()");
			shape.mouseEnabled = false;
			active = false;
			TweenLite.to(this,.25,{	scaleX:0,
									scaleY:0,
									ease:Back.easeIn,
									onComplete:dispatchEvent,
									onCompleteParams:[new Event('elementTokenHide',true)]});
									
//			setTimeout(dispatchEvent,1000,new Event('ElementTokenHide'));
		}				

		//---------------------------------------
		// EVENT HANDLERS
		//---------------------------------------
		
		public function handleOver(e:MouseEvent):void
		{
			dispatchEvent(new MouseEvent('elementTokenOver',true));
		}
	}
}