package net.manipulus
{

	import flash.display.*;
	import flash.events.*;

	public class Reference extends Object
	{
	
		public var object   :Object;
		public var property	:String;
	
		protected var previousValue	: ValueAtTime;
		protected var currentValue	: ValueAtTime;
		
		public var valueHistory	: Vector.<ValueAtTime>
		
		public var changeInValue 	: Number;
		public var velocity;
		
		public var lastTimeStamp 	: uint;
	
		protected var maxHistory		: uint	= 2000;
	
		public function Reference(object_:Object,property_:String, timeStamp_:uint = Infinity)
		{
			super();
			
			object        = object_;
			property      = property_;
			
			if(timeStamp_ == Infinity) timeStamp_ = new Date().getTime();
			
			currentValue  = previousValue = currentValue = new ValueAtTime(object[property],timeStamp_);	
			lastTimeStamp = timeStamp_;
			
			valueHistory  = new Vector.<ValueAtTime>();
			
			changeInValue = 0;
		}

		
		public function update(timeStamp_:uint):void
		{
			if(timeStamp_ == lastTimeStamp) return; //updating more than once! No can do!... or... it should re-write/overwrite

			//trace("Reference::update()",this);

			previousValue = currentValue;	
			currentValue  = new ValueAtTime(object[property],timeStamp_);

			changeInValue = currentValue.value - previousValue.value;	
//			velocity	  = changeInValue/timeDif;	
			
			valueHistory.push(currentValue);
			
			if(valueHistory.length == maxHistory) valueHistory.shift();
			
			lastTimeStamp = timeStamp_;
			
		}		

		public function isTo(object_:Object,property_:String=null):Boolean
		{
			if(property_==null) return object_ == object;
			else return (object_ == object && property_ == property);
		}
		
		public function toString():String
		{
			if(object is MovieClip) return object.name+' '+property/*+', changeInValue:'+changeInValue+', lastTimeStamp:'+lastTimeStamp*/;
			else return  object+' '+property/*+', changeInValue:'+changeInValue+', lastTimeStamp:'+lastTimeStamp*/;
			
		}

		public function set targetValue(val:*):void
		{
			object[property] = val;
		}
		
		public function get targetValue():*
		{
			return object[property];
		}
			
		public function set targetChangeInValue(val:Number):void
		{
			targetValue += val;
		}
		
		public function getValueAtTime(t:uint):Number
		{		
			var n = valueHistory.length-1;
			var valueAtTime = valueHistory[n];
			
			while(valueAtTime.timeStamp > t && n > 1)
			{
				n--;
				valueAtTime = valueHistory[n];
			}
			
			return valueAtTime.value;
		}
		
		public function changeInValueAtTime(t:uint):Number
		{
			if(t==lastTimeStamp) return changeInValue;
			
			var n = valueHistory.length-1;
			var valueAtTime = valueHistory[n];
			
			while(valueAtTime.timeStamp > t && n > 1)
			{
				n--;
				valueAtTime = valueHistory[n];
			}
			
			if(valueAtTime.timeStamp > t && n == 0) return 0;
			
			return valueAtTime.value - valueHistory[n-1].value;
			
		}
		
		public function changeInValueBetweenTimes(t1:uint,t2:uint):Number
		{
			return getValueAtTime(t2) - getValueAtTime(t1);
		}
		
		public function valueOf():*
		{
			return targetValue;
		}
	}
}
