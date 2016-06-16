// Can extendz MouseEvent?...

package net.manipulus.UI
{	

	import flash.events.Event;
	
	public class DragDropEvent extends Event
	{

		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		
		public static const DROP      : String = 'drop';
		public static const GRAB      : String = 'grab';
		public static const DRAG_OVER : String = 'dragOver';
		public static const DRAG_OUT  : String = 'dragOut';
		public static const PLACE     : String = 'place';

		public static const REFUSE_DROP:String = 'refuseDrop';
		public static const ACCEPT_DROP:String = 'acceptDrop';
		
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------

//		public var targetButton : DragButton;

		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------

		public function DragDropEvent(type_:String,bubbles_:Boolean=true,cancelable_:Boolean = false)
		{
			super(type_,bubbles_,cancelable_);
//			targetButton = target as DragButton;
		}

	}
}