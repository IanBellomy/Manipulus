package net.manipulus
{

	import flash.display.*;
	import flash.events.*;

	public class AngularReference extends Reference
	{
		public function AngularReference(object_:Object,property_:String, timeStamp_:uint = Infinity)
		{
			super(object_,property_, timeStamp_);
			//trace("AngularReference::AngularReference()");
		}
		
		override public function update(timeStamp_:uint):void
		{
			if(timeStamp_ == lastTimeStamp) return; //see note in Reference

			//trace("Reference::update()",this);

			previousValue = currentValue;	
			
			//calculate currentValue...
			var newInternalValue = object[property];
			var difference = newInternalValue - previousValue.value;
			var loops = 1;//Math.floor(previousValue.value/360) +1;			
			
			if(Math.abs(difference) > 180)
			{				
				(difference > 0)? newInternalValue -=360*loops: newInternalValue+=360*loops;
				difference =  newInternalValue - previousValue.value;
			}   
			
			currentValue  = new ValueAtTime(newInternalValue,timeStamp_);

			changeInValue = currentValue.value - previousValue.value;	
//			velocity	  = changeInValue/timeDif;	
			
			valueHistory.push(currentValue);
			
			if(valueHistory.length == maxHistory) valueHistory.shift();
			
			lastTimeStamp = timeStamp_;
			
		}	
		
		override public function get targetValue():*
		{
			return currentValue.value;
		}
		
	}
}