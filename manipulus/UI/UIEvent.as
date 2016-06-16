package net.manipulus.UI
{	
	public class UIEvent extends Event
	{

		public static const HIDE_COMPLETE 	 : String = 'hideComplete';	
		public static const REVEAL_COMPLETE  : String = 'revealComplete';	

		public function UIEvent(type_:String,bubbles_:Boolean)
		{
			super(type_,bubbles_);			
		}

	}
}