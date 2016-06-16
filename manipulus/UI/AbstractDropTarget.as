/*

	
			Stillborn.
		
		

*/

package net.manipulus.UI
{	
	public class AbstractDropTarget extends Sprite
	{

		public function AbstractDropTarget()
		{
			super();		
		}

		function handleOver(e:MouseEvent):void
		{
			// check for content? OR check for 
			// if content... check for handling? then
			// VIABLE_OVER?
			// UNVIABLE_OVER?
		}

		// Can we assume we'll recieve this?...
		// manager could capture... then pass along a dragOver in its place?? How??
		function handleDragOver(content:Object):void
		{
			
		}
		
		function handleDragOut(content:Object):void
		{
			
		}
		
		function handleDrop(content:Object):void
		{
			// if handle able.. DragDropEvent.ACCEPT_DROP
			// else 			DragDropEvent.REFUSE_DROP
		}
		
	}
}

// Option A : just wait for evnets

	handleDragOver(e) // target will receive an event when the mouse enters with the mouseDown
	
		// how will it know if there's content?
		// does it need to know? to animate as a receptor or not... when else would we drag over it though?
		//

// Option B: Just run with the revised dragging...
	
	// add a child clip for dragged content
	// comment out a lot of stuff
	// 