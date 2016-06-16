/*

	Need some kind of PickWhip Button...
		Cable / Connector / DragAndDroper / Dragger / DragToButton / DragButton
		
		needs to handle:

			default
			over
			dragging
			dragged out of base area
			dragged over viable object
			released
				released on target	/ -> parent needs to handle that shit.
				released on nothing	/ -> snap back
				released on self	/ -> nothing

	Need visuals
		default
		over
		
		dragging
		draggingOver
		
		hide()
		reveal()
		dim()
		recieve()

*/

package net.manipulus.UI
{	
	import flash.events.*;
	import flash.display.*;			
	import flash.filters.*;
	import flash.text.TextField;

	import net.manipulus.*;

	import com.greensock.*;

	public class PropertyToken extends DragButton implements iDropTarget
	{

		public var targetObject : Object;
		public var targetProp	: String;

		public var draggableClip;

		public function PropertyToken()
		{
			super();					
			draggableClip = dragClip; // hack
			draggableClip.mouseChildren = false;
			mouseChildren = false;
//			mouseEnabled = false;
			alpha = 0;
		}
		
		
		public function setContent(obj:Object,prop:String,propLabel:String)		
		{
			targetObject   = obj;
			targetProp     = prop;			
			dragClip.labelText.text = propLabel;	
		}
		
		//---------------------------------------
		// OVERRIDED PUBLIC METHODS
		//---------------------------------------
		
		override public function animateOver(e:Event=null):void
		{
			//trace("PropertyToken::animateOver()");
			TweenLite.to(draggableClip.backgroundClip,.1,{alpha:1,tint:0x6F838C});
			TweenLite.to(draggableClip.labelText,.1,{tint:0xffffff});
		}
		
		// when button is rollOuted
		override public function animateOut(e:Event=null):void
		{
			TweenLite.to(draggableClip.backgroundClip,.25,{alpha:0,tint:0xffffff});			
			TweenLite.to(draggableClip.labelText,.25,{tint:0x6F838C});
		}
		
		override public function animateGrab(e:Event = null):void
		{
			/*TweenMax.to(draggableClip,.25,{	//alpha:.25,
											//z:-10//,
											dropShadowFilter:{alpha:1,angle:85, blurX:8, blurY:8, color:0, distance:2, strength:.5, quality:3}
											});*/
		}
		
		override public function animateDrop(e:Event = null):void
		{
			TweenMax.to(draggableClip,.25,{alpha:1});
			/*super.animateDrop();
			TweenMax.to(draggableClip,.25,{ alpha:1,
											//z:0,
											dropShadowFilter:{alpha:0,angle:85, blurX:0, blurY:0, color:0, distance:0, strength:1, quality:3,remove:true},
											overwrite:false});*/
		}
		
		override public function animatePlace(targetItem:* = null):void
		{			
			TweenMax.to(draggableClip,.25,{alpha:1});
		}
		
		override public function animateDraggedOver(target:iDropTarget=null):void
		{
			TweenMax.to(draggableClip,.25,{	alpha:.25});
		}
		
		override public function animateDraggedOut(target:iDropTarget=null):void
		{
			TweenMax.to(draggableClip,.25,{	alpha:1});			
		}
	
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		public function reveal():void
		{
			TweenLite.to(this,.25,{alpha:1});
			//mouseEnabled = true;
		}
		
		public function hide():void
		{
			//hide
		}
		
		//---------------------------------------
		// EVENT HANDLERS for iDropTarget interface
		//---------------------------------------
		// when something else is dragged over
		public function animateEclipsed(content:DragButton=null):void		
		{
			//trace("PropertyToken::animateEclipsed() ",targetProp);
			animateOver();
//			TweenLite.to(this,0,{colorTransform:{tint:0xff9900,tintAmount:.25}});
//			filters = [new GlowFilter(0x000000,.5,10,10,1,1,true)];
//			alpha = .8;
		}
		
		// when something is dragged out
		public function animateUnEclipsed(content:DragButton=null):void	
		{
			//trace("PropertyToken::animateUnEclipsed() ",targetProp);
			animateOut();
//			TweenLite.to(this,.2,{colorTransform:{tint:0xff9900,tintAmount:0}});
//			filters = [];
			alpha = 1;
		}

		public function animateRecieve(n:DragButton = null):void
		{
			// flash then fade...?
			animateUnEclipsed(n);
//			TweenLite.to(this,0,{colorTransform:{tint:0xffffff}});
//			TweenLite.to(this,.25,{colorTransform:{tint:0xffffff,tintAmount:0},overwrite:false});
		}
		
		
		override public function animateDragFrom(e:Event=null):void
		{
			animateOut();
		}
		
		override public function animateDragBack(e:Event=null):void
		{
			animateOver();
		}
		
		//	
		//	overrides
		//
		
		override public function getDraggableContentRepresentation():DisplayObject
		{
			return new DraggedPropertyToken();
		}
	}
}
