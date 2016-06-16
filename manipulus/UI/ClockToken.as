package net.manipulus.UI
{	
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
		
	import com.greensock.*;
	import com.greensock.easing.*;
	
	import net.manipulus.*;
	import net.manipulus.UI.*;		
	
	public class ClockToken extends Sprite
	{
	
		public var targetElement:Class;	
		public var active : Boolean = false;
		public var shape : Sprite;
	
	
		public function ClockToken()
		{
			super();
			scaleX = 0;
			scaleY = 0;
			x = 450;
			y = 520;
			targetElement = Clock;
			addEventListener(MouseEvent.ROLL_OVER,handleOver);
			mouseChildren = false;
			filters = [new DropShadowFilter(4,85,0x000000,.5,10,10)];
		}
		
		public function reveal():void
		{
			active = true;
			mouseEnabled = true;
			TweenLite.to(this,.75,{	scaleX:1,
									scaleY:1,
									ease:Elastic.easeOut,
									onComplete:dispatchEvent,
									onCompleteParams:[new Event('elementTokenReveal',true)]});

		}
		
		public function hide():void
		{
//			trace("ElementToken::hide()");
			mouseEnabled = false;
			active = false;
			TweenLite.to(this,.25,{	scaleX:0,
									scaleY:0,
									ease:Back.easeIn/*,
																		onComplete:dispatchEvent,
																		onCompleteParams:[new Event('elementTokenHide',true)]*/});
									
//			setTimeout(dispatchEvent,1000,new Event('ElementTokenHide'));
		}	
	
		public function handleOver(e:MouseEvent):void
		{
			trace("ClockToken::handleOver()");
			dispatchEvent(new MouseEvent('elementTokenOver',true));
		}
		
	
	}
}
	