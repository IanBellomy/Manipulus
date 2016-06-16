package net.manipulus.UI
{	
	
	import flash.events.Event;	
	
	public class PropertiesCardEvent extends Event
	{
		public static const HIDE : String = 'hide';	
		public static const TOKEN_DRAG_OUT : String = 'tokenDragOut';
        public static const DELAYED_TOKEN_DRAG_OUT : String = 'delayedTokenDragOut';

//        public static const HIDE : String = 'hide';

		public function PropertiesCardEvent(type_:String,bubbles_:Boolean)
		{
			super(type_,bubbles_);
		}

	}
}