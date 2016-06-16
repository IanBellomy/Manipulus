/*

	Should this handle the transition between collapsed and uncollapsed?... prolly...

	Should this handle a dragged outside event?....
		grab: dragging	(need this to organize tokens too!)
		if drag outside, set timer
		if drag inside, kill timer
		if timer, dispatch drag outside event

	Events
	
		PropertiesCardEvent
			.DELAYED_DRAG_TOKEN_OUT
			.DRAG_TOKEN_OUT
			.DRAG_TOKEN_OVER_COLLAPSED
			...

*/

package net.manipulus.UI
{	

	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.geom.*;
	import flash.filters.*;
	import com.greensock.*;
	import com.greensock.easing.*;
		
	import net.manipulus.*;

	public class PropertiesCard extends Sprite
	{

		public var springLoaded : Boolean = false;

		public var targetEntity	: Object
		public var tokens 		: Array;		
		public var hidden		: Boolean = true;

		protected var draggedToken : PropertyToken;
		protected var dragOutTimerID : int = -1;
		protected var dragOutTimeLimit : int = 10;

		protected var boundsRectangle : Rectangle;
		
		private var contentMask : Sprite;
		
		protected var backgroundLayer : Sprite;
		protected var propertyTokensLayer : Sprite
		protected var mappingTokensLayer : Sprite
		
		protected var mappingTokens : Dictionary;
		protected var inputTokens		 : Dictionary;
		protected var outputTokens		 : Dictionary;
		
		protected var propertyTokens	 : Dictionary;
		protected var tokenDestinationPreviewClip : TokenDestinationPreviewClip;
		protected var tokenSourcePreviewClip	  : TokenDestinationPreviewClip;
		
		public function PropertiesCard()
		{
			super();
			
			trace("PropertiesCard::PropertiesCard()");
			
			alpha = 0;
			backgroundLayer = new Sprite();
			propertyTokensLayer = new Sprite();
			mappingTokensLayer = new Sprite();					
			
			addChild(backgroundLayer);
			addChild(propertyTokensLayer);
			addChild(mappingTokensLayer);
			
			mappingTokensLayer.filters = [new DropShadowFilter(2.8,45,0x000000,.5,5,5,1,3)];
			mappingTokensLayer.mouseEnabled = false;
			
			mappingTokens 	= new Dictionary();
			propertyTokens		= new Dictionary();
			inputTokens 		= new Dictionary();
			outputTokens        = new Dictionary();
			
			Binder.addEventListener(RelationshipEvent.MAPPING_CREATED,handleRelationshipCreated,false,0,true);
			Binder.addEventListener(RelationshipEvent.MAPPING_REMOVED,handleRelationshipRemoved,false,0,true);
						
		}
		
		// 'props' is string with property names and labels
		public function init(obj:Object,props:String):void
		{
			trace("PropertiesCard::init()");
			// 
			var propArray :Array = props.split(',');
			
			//trace(propArray.length);
			
			// populate
			targetEntity = obj;
			
			tokens = [];			
			
			var n = 0;
			var propString:String;
			var propLabel:String;
			
			
			backgroundLayer.graphics.lineStyle(1,0xEAEAEA,.25);
			backgroundLayer.graphics.moveTo(0,12);
			backgroundLayer.graphics.lineTo(120,12);
			
			var propertyToken : PropertyToken;
			
			for each(var propPair : String in propArray)
			{				
			
				propertyToken   = new PropertyToken();
				propertyToken.y = n * propertyToken.height + 12;					
			
				backgroundLayer.graphics.moveTo(0,propertyToken.y+propertyToken.height);
				backgroundLayer.graphics.lineTo(120,propertyToken.y+propertyToken.height);
				
				propString 	= propPair.split(':')[0]; 
				propLabel 	= propPair.split(':')[1];							
								
				if(propLabel == null) propLabel = propString;
				
				propertyTokensLayer.addChild(propertyToken);				
				
					propertyToken.alpha = 0;
					propertyToken.init();
					propertyToken.setContent(obj,propString,propLabel);
				
				tokens.push(propertyToken);	
				propertyTokens[propString] 	= propertyToken;
				inputTokens[propString] 	= new Vector.<RelationshipToken>();
				outputTokens[propString] 	= new Vector.<RelationshipToken>();			
					
				n++;
			}					
			
			// show mappings
			var matches:Array = Binder.getRelationshipsInvolving(targetEntity);
			
			for each(var mapping:Relationship in matches)
			{
				showRelationshipToken(mapping);				
			}	
					
			backgroundLayer.graphics.beginFill(0xFFFFFF);
			backgroundLayer.graphics.drawRoundRect(0,0,propertyTokensLayer.width,propArray.length*21+12+12,12,12);
			backgroundLayer.graphics.endFill();									
			
			/*contentMask = new Sprite();
			contentMask.graphics.beginFill(0x000000);
			contentMask.graphics.drawRoundRect(0, 0, width, height, 10, 10);
			contentMask.graphics.endFill();                 
			//contentMask.mouseChildren = false;
			//contentMask.mouseEnabled = false;
			
			addChildAt(contentMask,0);			
			mask = contentMask;*/
			
			
			filters = [new DropShadowFilter(4,85,0x000000,.5,10,10)];
			
			// for dragging in out
			boundsRectangle = new Rectangle(0,0,propertyTokensLayer.width,height);
			
			// hide?			
			
			// add listeners?
			addEventListener(DragDropEvent.GRAB,handleGrab);
			addEventListener(DragDropEvent.DROP,handleRelease);
			addEventListener(DragDropEvent.PLACE,handleRelease);
			addEventListener(MouseEvent.ROLL_OVER,handleRollOver);
			addEventListener(MouseEvent.ROLL_OUT,handleRollOut);
			addEventListener(PropertiesCardEvent.DELAYED_TOKEN_DRAG_OUT,hide);
			// addEventListener(MouseEvent.ROLL_OUT,handleRollOut);			
			
			trace("PropertiesCard::init()");
		}		
		
		public function listProperties(props:Array = null):void
		{
			
			
		}
		
		public function reveal():void
		{
			mouseChildren = true;
			TweenMax.allTo(tokens,0,{alpha:1});			
			alpha = .0;
			y-=5;
			TweenLite.to(this,.5,{alpha:1,y:'5',ease:Quint.easeOut});
			hidden = false;
			
			if(y + height >= stage.stageHeight-75)
			{
				y = stage.stageHeight - height - 75;
			}
		}

		public function hide(e:Event=null):void
		{
			mouseChildren = false;
			mouseEnabled = false;
			TweenMax.allTo(tokens,.5,{alpha:0},.05);
			TweenLite.to(this,.5,{alpha:0,y:'5'});			
			hidden = true;
			setTimeout(dispatchEvent,.5,new PropertiesCardEvent(PropertiesCardEvent.HIDE,true));
		}
		
		//---------------------------------------
		// EVENT HANDLERS
		//---------------------------------------

		public function handleRollOver(e:MouseEvent):void
		{
			if(dragOutTimerID != -1) 
			{				
				// shouldn't happen if hidden or collapsed...				
				clearTimeout(dragOutTimerID);
				dragOutTimerID = -1;				
			}
			if(e.buttonDown) springLoaded = true;
		}
		
		public function handleRollOut(e:MouseEvent):void
		{
			if(!springLoaded) return;
			if(!e.buttonDown){ hide(); return;}
			if(dragOutTimerID == -1)
			{ 
				dispatchEvent(new Event(PropertiesCardEvent.TOKEN_DRAG_OUT));
				dragOutTimerID = setTimeout(dispatchEvent,dragOutTimeLimit, new PropertiesCardEvent(PropertiesCardEvent.DELAYED_TOKEN_DRAG_OUT,true) );
			}
		}

		// one of the containing tokens was grabbed...
		public function handleGrab(e:DragDropEvent):void
		{			
			propertyTokensLayer.addChild(e.target as DisplayObject);
			draggedToken = e.target as PropertyToken;
			springLoaded = true;
//			addEventListener(Event.ENTER_FRAME,handleEnterFrame)	// do not want.
		}
		
		public function handleRelease(e:DragDropEvent):void		
		{
			draggedToken = null;
			clearTimeout(dragOutTimerID);
			dragOutTimerID = -1;
			trace("PropertiesCard::handleRelease()");
		}
		
		public function handleDragOutside(e:Event)
		{
			trace("PropertiesCard::handleDragOutside()");	// oooooooo can't hide this without removing draggedItem... HMMM
			hide();	
		}
		
		public function handleDragInside(e:Event)
		{
			trace("PropertiesCard::handleDragInside()");
		}
		
		// psedo listeners
		// preview driver...
		
		public function previewDropTarget(targetToken:PropertyToken,dropLocation:String,sourceToken:PropertyToken = null):void
		{
			
			tokenDestinationPreviewClip = new TokenDestinationPreviewClip();			
			tokenDestinationPreviewClip.y = targetToken.y + targetToken.height/2; 
			tokenDestinationPreviewClip.mouseEnabled = false;
			tokenDestinationPreviewClip.mouseChildren = false;
			
			switch(dropLocation)
			{
				case 'left':
					// is valid?
					// are there existing tokens?
					tokenDestinationPreviewClip.x = -3 - (20 * inputTokens[targetToken.targetProp].length);						
					break;
				
				case 'right':
					// is valid?
					// are there existing tokens?					
					tokenDestinationPreviewClip.x = targetToken.width + 3 +  (20 * outputTokens[targetToken.targetProp].length);
					break;
				
				case 'both':
					// is valid?
					// are there existing tokens?
//					var token 2 = 
//					tokenDestinationPreviewClip.x = 0;	
//					tokenDestinationPreviewClip.x -= 5;														
					break;
			}
			
			mappingTokensLayer.addChild(tokenDestinationPreviewClip);
			
			//
			// if sourceToken is ON this card
			//			
			
			if(sourceToken != null && sourceToken.targetObject == targetEntity)
			{
				if(tokenSourcePreviewClip == null) tokenSourcePreviewClip = new TokenDestinationPreviewClip();
				tokenSourcePreviewClip.y = sourceToken.y + sourceToken.height/2;
				switch(dropLocation)
				{
					case 'right':
						// dragging to the right of something, source should be on the left
						// is valid?
						tokenSourcePreviewClip.x = -3 - (inputTokens[sourceToken.targetProp].length*20);
						break;

					case 'left': 
						// target is left, this preview needs to be on the right
						// is valid?
						trace(inputTokens[sourceToken.targetProp].length);
						tokenSourcePreviewClip.x = 3 + sourceToken.width + (outputTokens[sourceToken.targetProp].length * 20);
						break;

					case 'both':
						// is valid?
						// are there existing tokens?
	//					var token 2 = 
	//					tokenDestinationPreviewClip.x = 0;	
	//					tokenDestinationPreviewClip.x -= 5;
						break;
				}
				mappingTokensLayer.addChild(tokenSourcePreviewClip);
			}
		}
		
		public function unPreviewDropTarget():void
		{
			if(tokenDestinationPreviewClip !=null) mappingTokensLayer.removeChild(tokenDestinationPreviewClip);
			tokenDestinationPreviewClip = null;
			// we'll need to remove more eventually...			
/*			for(var i = mappingTokensLayer.numChildren-1; i > -1; i-- )
			{
				mappingTokensLayer.removeChildAt(i);
			}*/
			
			//
			// if sourceToken is ON this card
			//	
			
			if(tokenSourcePreviewClip != null)
			{
				mappingTokensLayer.removeChild(tokenSourcePreviewClip);
				tokenSourcePreviewClip = null;
			} 
			
		}
		
		public function showRelationshipToken(mapping:Relationship,animateReveal:Boolean = false):void
		{			
			
			// A single mapping may have to be represented more than once if its from one property to another of the same element/object/target/entitiy
			var mappingToken 		 : RelationshipToken;
			var propertyString		 : String;
			var relatedPropertyToken : PropertyToken;
						
			// if the mapping is TO this target
			if(mapping.isTo(targetEntity))
			{
				trace('inputs',inputTokens[propertyString]);
				// is 'driven'
				mappingToken 		= new RelationshipToken();
				propertyString		 	= mapping.driven.property;
				relatedPropertyToken 	= propertyTokens[propertyString];				
								
				mappingToken.x = -3  - (inputTokens[propertyString].length * 20);
				mappingToken.y = relatedPropertyToken.y+relatedPropertyToken.height/2;				
				
				inputTokens[propertyString].push(mappingToken);
				mappingTokensLayer.addChild(mappingToken);
			}
			
			// if the mapping is FROM this target
			if(mapping.isFrom(targetEntity))
			{				
				trace('outputs',outputTokens[propertyString]);
																
				// is 'driver'
				mappingToken 		 = new RelationshipToken();
				propertyString		 	 = mapping.driver.property;
				relatedPropertyToken 	 = propertyTokens[propertyString];				
				
				mappingToken.x = relatedPropertyToken.width + 3 + (outputTokens[propertyString].length * 20);
				mappingToken.y = relatedPropertyToken.y+relatedPropertyToken.height/2;
				
				
				outputTokens[propertyString].push(mappingToken);
				mappingTokensLayer.addChild(mappingToken);
			}			

		}
		
		public function hideRelationshipToken(mapping):void
		{			
			// derp
		}
		
		//
		//
		//
		public function handleRelationshipCreated(mapperEvent:RelationshipEvent):void
		{
			showRelationshipToken(mapperEvent.mapping);
		}
		
		public function handleRelationshipRemoved(mapperEvent:RelationshipEvent):void
		{
			hideRelationshipToken(mapperEvent.mapping);
		}
		
	}
}