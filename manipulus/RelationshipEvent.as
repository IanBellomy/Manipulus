package net.manipulus
{

	import flash.events.*;
	import net.manipulus.*;

	public class RelationshipEvent extends Event
	{
	
		public static const MAPPING_CREATED : String = 'mappingCreated';
		public static const MAPPING_REMOVED : String = 'mappingRemoved';
		
		public var mapping : Relationship;
	
		public function RelationshipEvent(type_:String,mapping_:Relationship)
		{
			super(type_);		
			mapping = mapping_;
		}		

	}

}
