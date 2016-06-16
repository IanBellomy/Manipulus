package net.manipulus
{

	public class RandomNumberReference extends Reference
	{

		public var high 	: Number = 1;
		public var low 		: Number = 0;
		public var stepSize	: Number = 0;

		public function RandomNumberReference(low_:Number=0,high_:Number=1,stepSize_:Number=0){						
			low = low_;
			high = high_;
			stepSize = stepSize_;
			super({name:"RandomeNumberReference"},"IRRELEVANT", Infinity);
		}

		override public function set targetValue(val:*):void{
			return;
		}
		
		override public function get targetValue():*{
			if(stepSize>0) return (Math.floor(Math.random()*(high/stepSize-low/stepSize)))*stepSize + low;
			else return Math.random()*(high-low)+low;
		}

		override public function toString():String{
			return "Mutable random number: low: "+low+" high:"+high+" stepSize:"+stepSize;
		}
	}
}