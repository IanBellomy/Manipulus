package net.manipulus
{	
	public class Parser extends Object
	{
		
		public static var stage_:Stage;

		public function Parser()
		{
			super();
		}
		
		
		public static function parse(clip:DisplayObject,statement:String):Relationship
		{
									
			var clip;
			var referenceStrings;
			var driverReference ;
			var drivenReference ;			

			statement = statement.split(' ').join(''); // strip whitespace
			
			if(statement.search("->") != -1) 
			{
				// split on 
				referenceStrings = statement.split('->');				
				
				driverReference = getReferenceFromString(clip,referenceStrings[0]);
				drivenReference = getReferenceFromString(clip,referenceStrings[1]);
								
				// bind changes				
				return Binder.bindChanges(drivenReference,'targetValue',driverReference,'targetValue');
			}
			else
			{
				referenceStrings = statement.split('=');
				driverReference = getReferenceFromString(clip,referenceStrings[1]);
				drivenReference = getReferenceFromString(clip,referenceStrings[0]);

				return Binder.bind(driverReference,'targetValue',drivenReference,'targetValue');
			} 
			
			
		}
		
		public static function getReferenceFromString(clip,referenceString):Reference
		{
			if(clip == null)
			{
				trace("Binder::getReferenceFromString(referenceString) ERROR: Binder needs reference to stage. Binder.init(stage) was probably not called...");
				return null;
			}
			var objectString	= referenceString.split(".")[0];
			var propertyString  = referenceString.split(".")[1];
			
			if(objectString == "Cursor") return createReference(Cursor,propertyString); // "Cursor" does ot resolve to Cursor via getDefinitionByName(), it needs to be "net.manipulus.Cursor" :/
			else if(objectString == "Metronome") return createReference(Metronome,propertyString);
			/*else if(getDefinitionByName(objectString) != null)
			{
				return createReference(getDefinitionByName(objectString),propertyString);
			}*/
			else if(objectString == "this") return createReference(clip,propertyString);						
			else if(clip[objectString]==null)
			{
				trace("Binder::getReferenceFromString(referenceString) ERROR "+objectString+" does not exist on stage.");	
				return null;
			}
			else return Binder.createReference(clip[objectString],propertyString);
			
		}

	}
}