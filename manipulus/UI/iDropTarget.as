/*

		What should this implement?...
		
			animateEclipsed(content:DragButton)		// when something is dragged over
			animateUnEclipsed(content:DragButton)	// when something is dragged out
			animateHilight()						// to show as target...
			animateUnHilight()
			
*/

package net.manipulus.UI
{	
	
	
	public interface iDropTarget
	{

		function animateEclipsed(content:DragButton=null):void	// when something is dragged over		
		function animateUnEclipsed(content:DragButton=null):void 	// when something is dragged out
		function animateRecieve(content:DragButton=null):void	// when something is released on it. 

		/*function handleDragOver(content:Object):void
		function handleDragOut(content:Object):void
		function handleDrop(content:Object):void*/
		
		
//		animateHilight()						// to show as target...
//		animateUnHilight()

	}
}