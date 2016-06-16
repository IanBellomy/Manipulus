package net.manipulus
{

	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	
	public class Box extends Sprite
	{
		
		private var _x 			: Number;
		private var _y 			: Number;
		private var _rotation 	: Number;
		
		private var _anchorPointXOffset : Number = 0;
		private var _anchorPointYOffset : Number = 0;		
		
		private var _graphic 	: Sprite; 
					
		private var _Top		: Number = -25;
		private var _Bottom 	: Number = 25;
		private var _Left		: Number = -25;
		private var _Right 	: Number = 25;
	
		public var grouped : Boolean = false;		
		
		private var _clr;
		
		public function Box(clr:uint=0)
		{
			super();
												
			_x = super.x;
			_y = super.y
			_rotation = super.rotation;		
			_clr = clr;
			
			_graphic = new Sprite();
			addChild(_graphic);
						
//			addEventListener(MouseEvent.MOUSE_DOWN,handleDown);
//			addEventListener(MouseEvent.MOUSE_UP,handleUp);			
			
			buttonMode = true;
			mouseChildren = false;	
			
			refresh();
//			addEventListener(Event.ENTER_FRAME,refresh);
		}		

		
		public function handleDown(e):void
		{
			trace("Box::handleDown()");
//			Binder.drag(this);
//			stage.addEventListener(MouseEvent.MOUSE_UP, handleUp);
//			dispatchEvent(new Event('ElementDown',true));
		}
		
		public function handleUp(e):void
		{
//			Binder.stopDrag(this);
//			Binder.unmap(parent,'mouseX',this,'x');
//			Binder.unmap(parent,'mouseY',this,'y'); 	
//			stage.removeEventListener(MouseEvent.MOUSE_UP, handleUp);
		}
						
		public function set anchorPointX(n:Number):void
		{
			var delta 	= n-x;
			x			= n;
						
			_graphic.x	+= Math.cos(_rotation * Math.PI/180)*-delta;
			_graphic.y	+= Math.sin(_rotation * Math.PI/180)*delta;
		}
		
		public function get anchorPointX():Number
		{
			return x;
		}
		
		public function set anchorPointY(n:Number):void
		{
			var delta 	= n-y;
			y			= n;

			_graphic.x	+= Math.sin(_rotation * Math.PI/180)*-delta;
			_graphic.y	+= Math.cos(_rotation * Math.PI/180)*-delta;
		}		
		
		public function get anchorPointY():Number
		{
			return _anchorPointYOffset;
		}
		
		public function setParent(p:Sprite)
		{
			anchorPointX = p.x;
			anchorPointY = p.y;
		}

		override public function set y(n:Number):void
		{
			_y = n;
			super.y = n;
//			super.y = (n+500)%500;
		}
		
		override public function get y():Number
		{
			return _y;
		}

		override public function set x(n:Number):void
		{
			_x = n;
			super.x = n;
//			super.x = (n+500)%500;
		}
		
		override public function get x():Number
		{
			return _x;
		}

		public function set scale(n:Number):void
		{
			scaleX = n;
			scaleY = n;
		}
		
		override public function get rotation():Number
		{
			return _rotation;
		}
		
		override public function set rotation(n:Number):void
		{
			_rotation = n;
//			_graphic.rotation = n;
			super.rotation = n;
		}
		
		public function get scale():Number
		{
			return scaleX;
		}
		
		//
		//		Bounds
		//
		
		public function get Left():Number
		{
			return _Left;
		}	
		
		public function set Left(value:Number):void
		{
			_Left = value;
			refresh();
		}
		
		public function get Right():Number
		{
			return _Right;
		}
		public function set Right(value:Number):void
		{
			_Right = value;
			refresh();
		}
		
		public function get Top():Number
		{
			return _Top;
		}
		public function set Top(value:Number):void
		{
			_Top = value;
			refresh();	
		}
		
		public function get Bottom():Number
		{
			return _Bottom;
		}
		public function set Bottom(value:Number):void
		{
			_Bottom = value;
			refresh();
		}

		public function get color():uint
		{
			return _clr
		}

		public function set color(val:uint):void
		{
			// not suported yet...
			_clr = val;
			refresh();
		}

		public function get touched():Boolean
		{
			var p = new Point(mouseX,mouseY);
				p = localToGlobal(p);
			return hitTestPoint(p.x,p.y);
		}

		public function set touched(val:Boolean):void
		{
			// not supported...
		}
	
		override public function toString():String
		{
			return name;
		}
	

		//
		//
		//

		/*public function getRect():Rectangle
		{
			return new Rectagle(x-_Left,y-_Top,width,height);
		}*/
		
		//
		//
		//
		
		public function refresh(e:Event = null):void
		{
			_graphic.graphics.clear();
			_graphic.graphics.beginFill(_clr);
			_graphic.graphics.moveTo(_Left,_Top);
			_graphic.graphics.lineTo(_Right,_Top);	
			_graphic.graphics.lineTo(_Right,_Bottom);	
			_graphic.graphics.lineTo(_Left,_Bottom);										
			_graphic.graphics.endFill();
		}
		
		
		//
		//
		//
		
		// "Five by Five"
		public static function faith(x_,y_,spacing:Number):Array
		{
			var bunch = [];
			for(var i = 0 ; i < 25; i++)
			{
				var b = new Box();
					b.x = i%5*b.width + x_;
					b.y = Math.floor(i/5)*b.height + y_;
					
				bunch.push(b);
			}
			return bunch;
			
		}
		

	}
	
}