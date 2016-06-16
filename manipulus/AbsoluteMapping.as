package net.manipulus
{

	public class AbsoluteRelationship extends Relationship
	{
	
		public function AbsoluteRelationship()
		{
			super();			
		}

		override public function apply(driver,driven):void
		{
			driven.targetValue = driver.targetValue;
		}

		public function resolve(timeStamp:uint):void
		{
			
			if(lastTimeStamp == timeStamp || suspend) return;
			
			// assuming a 'delta map' 
			if(delay == 0)
			{
				driven.object[driven.property] = driver.targetValue;
			}
			else
			{
				// this won't support a chaning delay value... :/
				driven.object[driven.property] = driver.getValueAtTime(timeStamp-delay));
			}
						
			lastTimeStamp = timeStamp;
		}		

		
	}

}
