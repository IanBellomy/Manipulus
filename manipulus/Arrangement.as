/*


	Keeps an array of display objects arranged in a certain way. 
	
		Default behavior is the creation of a stacked vertical list  (HTML block behavior)
		
		It assumes that the origin for each element is in the upper left....		

		
	Clips that have visible = false are not included in spacing.
	
		Clip as block? Check for these possible things?
			"display" 
			"margins"
			"left,right,top,bottom"
			"position" (relative,absolute,fixed)
	

	De-Incorporate with manipulus? Stand alone class?
		
		What happens when this and manipulus intersect?
		Basically... the arrangment becomes the driver for everything...?
		So... you click and drag a box in the arrangement...
 			The input should have priority and move.
			There should be feedback that the box is not draggable...
			

*/

package net.manipulus
{	

	import flash.display.*;
	
	public class Arrangement extends Set
	{

		public var verticalSpacing:Number = 0.0;
		public var distributeVertical:Boolean = true;
		public var distributeHorizontal:Boolean 
		
		public function Arrangement()
		{
			super();
		}
		
		public function arrange():void
		{
			
			if(distributeVertical)
			{
				
				var block:DisplayObject;
				var verticalPosition = this[0].y + this[0].height + verticalSpacing;
				for(var i = 1; i < _array.length; i++)
				{
					block = this[i];
					block.y = verticalPosition;
					//if(block['margin_top'])
					if(block.visible)
					{ 
						verticalPosition += block.height + verticalSpacing;
						//if(block['margin_bottom'])
					}
					// if(block['top'])
					// if(block['bottom'])
				}
			}
			
		}
		
		public function set left(n:Number):void
		{
			// move first item and refresh			
		}	
		
		public function set right(n:Number):void
		{
//			return this[legth-1].width;
		}	
		
		public function set top(n:Number):void
		{
//			return this[i].y;
		}
		
		public function set bottom(n:Number):void
		{
			//return this[length-1].y+this[length-1].height;
		}
	
		public function get height():Number
		{
			return this[length-1].y+this[length-1].height - this[0].y
		}
		
		public function set height(n:Number):void
		{
			// move last item and refresh
		}		
	
		public function set width(n:Number):void
		{
			// move last item and refresh
		}
	

	}
}