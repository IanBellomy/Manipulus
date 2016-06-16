package net.manipulus
{

	public class ValueAtTime extends Object
	{

		public var value        :Number;
		public var timeStamp	:uint;
	
		public function ValueAtTime(value_:Number,timeStamp_:uint)
		{
			value 		= value_;
			timeStamp 	= timeStamp_;
		}
		
		public function valueOf():Number
		{
			return value;
		}
		
		public function toString():String
		{
			return "[ValueAtTime "+value+" at "+timeStamp+"]";
		}

	}

}
