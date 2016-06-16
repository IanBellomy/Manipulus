/*

	This should be named differently...
	
		Sandbox?
		Playpen?
		Window?
		WorkArea?
		Box Home
		LiveSpace
		LivingRoom
		Den

	//
	
		Events
			
			TOKEN_PLACED
			
			ENTER_EDIT_MODE (?)
			EXIT_EDIT_MODE (?)
		
				Should the main app here somthign like this?
				Should the main app be responsible for triggering these things.				
				The main app can be responsible for handling the drag and drop?
					It'd be different than the tokens...
					mmm
					
	//
	
		layers
		
			background
			boxes/content
			content mask
			overlay / selection hilights
			tokens / cards
			
		
	//
	
		makeBox(x,y,color)
		removeBox(Box);
		hoverElement(Element)
		hoverElements(Array)
			
		enterEditMode()
		exitEditMode()
		showElementTokens()
		hideElementTokens()

		
		handleBoxOver(MouseEvent)		
		handleCardDragOut(CardEvent)
		handlePlaceToken(DragDropEvent)
		handleDropToken(DragDropEvent)

		handleTokenEclipsed(DragDropEvent)
		handleTokenUnEclipsed(DragDropEvent)

*/

package net.manipulus.UI
{	
	
	import flash.events.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
		import flash.filters.DropShadowFilter;
			import flash.filters.GlowFilter;
				import flash.ui.Keyboard;
	
	
	import net.manipulus.*;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	import flash.geom.Point;
	

	
	public class TableTop extends Sprite
	{
		
		public var backgroundLayer 		: Sprite;
//		public var previewLayer			: Bitmap;	// depricated
		public var contentLayer	   		: Sprite;
		public var contentMask			: Sprite;
		public var selectionLayer		: Sprite;
		public var tokenLayer			: Sprite;
		public var dragSourceLayer  	: Sprite;			
		public var foregroundLayer 		: Sprite;
		
		public var boxPositions 		: Array;
		
		public var dragSelecting		: Boolean = false;
		public var editing				: Boolean = false;
		public var startDragX			: int = 0;
		public var startDragY			: int = 0;		
	
		//
		//
		//
		
		public var elements				: Array;
		
		//
		//
		//
		
		public var hoveredElementOverlays	: Dictionary;		
		public var selectedElement			: Box;	// the box that's been clicked

		
		//
		// from properties token test
		//
		
		public var activeCard 		: PropertiesCard;	// source card...
		public var cards			: Array;
		public var elementTokens	: Array;
		public var grabbingToken 	: Boolean 			= false;
		public var dragging 		: Boolean 			= false;
		public var dragSource 		: DragButton;
		public var dragSourceCard	: PropertiesCard;
		public var dragSourceRepresentation : DisplayObject;

		public var currentDropTarget 	: iDropTarget;
		public var currentDropTargetArea: String = null;

		public var miscTokens		: Array;
		
		function TableTop()
		{
			boxPositions = [];
			elements     = [];
			cards        = [];
			elementTokens= [];
			miscTokens	 = [];
			
			if(stage != null) init();
		}
		
		public function init()
		{
			backgroundLayer = new Sprite();
//			previewLayer    = new Bitmap();
			contentLayer    = new Sprite();
			contentMask     = new Sprite();
			selectionLayer	= new Sprite();
			tokenLayer		= new Sprite();
			foregroundLayer = new Sprite();
			dragSourceLayer = new Sprite();
			
//			previewLayer.bitmapData = new BitmapData(500,500,true,0xffffffff);
			
			addChild(backgroundLayer);
//			addChild(previewLayer);
			addChild(contentLayer);
			addChild(contentMask);
			addChild(selectionLayer);
			addChild(tokenLayer);
			addChild(foregroundLayer);
			addChild(dragSourceLayer);
			
			dragSourceLayer.mouseChildren = false;
			dragSourceLayer.mouseEnabled = false;
			dragSourceLayer.filters = [new DropShadowFilter(2.8,45,0x000000,.5,5,5,1,3)];
			
			foregroundLayer.filters = [new DropShadowFilter(1,90,0x000000,1,3,3,1,3)];
						
			backgroundLayer.graphics.beginFill(0xffffff);
			backgroundLayer.graphics.drawRect(0,0,500,500);
			backgroundLayer.graphics.endFill();			
			
			contentMask.graphics.beginFill(0);
			contentMask.graphics.drawRect(0,0,500,500);
			contentMask.mouseEnabled = false;
			contentLayer.mask = contentMask;			
			
			// set the perspective for the content layer
			var pp:PerspectiveProjection = new PerspectiveProjection();
				pp.projectionCenter      = new Point(250,250);
			contentLayer.transform.perspectiveProjection = pp;				
			
			selectionLayer.mouseChildren = false;
			selectionLayer.mouseEnabled   = false;

			var clockToken = new ClockToken();
				/*clockToken.x = 504;
				clockToken.y = 480;*/
			tokenLayer.addChild(clockToken);
			miscTokens.push(clockToken);
			
			var metronomeToken = new MetronomeToken();
			tokenLayer.addChild(metronomeToken);
			miscTokens.push(metronomeToken);
			

			hoveredElementOverlays = new Dictionary();
			
			stage.addEventListener(MouseEvent.MOUSE_UP,handleMouseUp);
//			stage.addEventListener(Event.ENTER_FRAME,handleEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,handleMouseMove);	// 
			
			addEventListener('ElementDown',handleElementDown);
			backgroundLayer.addEventListener(MouseEvent.MOUSE_DOWN,handleBackgroundDown);
			
			addEventListener(DragDropEvent.GRAB,handleGrab);
			addEventListener(DragDropEvent.DROP,handleDrop,true);
			addEventListener('tokenRelease',handleTokenRelease);
			
			addEventListener(PropertiesCardEvent.HIDE,handlePropertiesCardHide);
			addEventListener(PropertiesCardEvent.DELAYED_TOKEN_DRAG_OUT,handleDelayedTokenDragOutFromCard);
			
			addEventListener('elementTokenHide',handleElementTokenHide);
			addEventListener('elementTokenOver',handleElementTokenOver);
			
			//
			addEventListener(MouseEvent.MOUSE_OVER,handleMouseOverCapture,true);
			addEventListener(MouseEvent.ROLL_OVER,handleMouseOverCapture,true);			
			addEventListener(MouseEvent.MOUSE_DOWN,handleElementDownCapture,true);
			
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		//
		//
		//
		public function makeBox(x_,y_,clr):Box
		{
			
			// create element
			var b = new Box(clr);
				b.x = x_;
				b.y = y_;
				b.name = 'Box_'+(contentLayer.numChildren+1);
				
			// set perspective
			/*var pp:PerspectiveProjection = new PerspectiveProjection();
			pp.projectionCenter = new Point(250+b.x,250+b.y);
			b.transform.perspectiveProjection = pp;*/
			
			// place so we can see...
			contentLayer.addChild(b);

			b.addEventListener(MouseEvent.ROLL_OVER,handleElementOver,false,0);
			b.addEventListener(MouseEvent.ROLL_OUT,handleElementOut,false,0);			
//			b.addEventListener(MouseEvent.MOUSE_DOWN,handleElementDown,false,0,true);
			
			elements.push(b);
			
			return b;
		}

		//
		//
		// generic add element?
		public function addElement(e:Sprite):void
		{
			contentLayer.addChild(e);
		}
		
		//
		//	3D view
		//
		public function showLayers():void
		{

			boxPositions = [];
			var spacing : Number= 200/contentLayer.numChildren;
			var layer : Sprite;
			
			for(var i : uint = 0; i < contentLayer.numChildren; i++)
			{
				layer = contentLayer.getChildAt(i) as Sprite; 		
				boxPositions.push(layer.y);
				TweenLite.to(layer,.5,{alpha:.15+(i/contentLayer.numChildren)*.85,rotationX:-45,y:150 + spacing*(contentLayer.numChildren-i), ease:Quint.easeOut});

				//if(box.clr = 0x000000) TweenLite.to(layer.box,.5,{tint:0x555555});
				//else TweenLite.to(layer.box,.5,{tint:0xDDDDDD});
			}						
			TweenMax.to(backgroundLayer,.5,{tint:0xaaaaaa});
			TweenMax.to(contentLayer,.5,{colorTransform:{tint:0x33ffff, tintAmount:0.2}});
		}
		
		//
		//	return to 2D view
		//
		public function hideLayers():void
		{
			var layer : Sprite;
			for(var i : uint = 0; i < contentLayer.numChildren; i++)
			{
				layer = contentLayer.getChildAt(i) as Sprite;		
				TweenLite.to(layer,.5,{alpha:1,rotationX:0,y:boxPositions[i],ease:Quint.easeOut});

				//if(box.clr = 0x000000) TweenLite.to(layer.box,.5,{tint:0x555555});
				//else TweenLite.to(layer.box,.5,{tint:0xDDDDDD});
			}	
			TweenMax.to(backgroundLayer,.7,{tint:0xffffff});
			TweenMax.to(contentLayer,.5,{colorTransform:{tint:0x33ffff, tintAmount:0}});
		}
		
		//
		//
		//
		public function enterEditMode()
		{
			editing = true;
			
			Clock.stop();
			Metronome.stop();
			
//			previewLayer.bitmapData.draw(contentLayer);
			TweenMax.to(backgroundLayer,0,{tint:0xbbbbbb});
			TweenMax.to(contentLayer,0,{colorTransform:{color:0xbbbbbb,tintAmount:.4}});
//			TweenMax.to(previewLayer,.25,{alpha:.5,z:20});
//			TweenMax.to(contentLayer,.25,{z:-20,colorTransform:{tint:0x33ffff, tintAmount:.2},alpha:1});

			// is there something under the cursor?
			var p = new Point(mouseX,mouseY);
				p = localToGlobal(p);
				
			var elementOnTop : Box = null;
			var box : Box          = null;
			
			for(var i:int = 0; i < contentLayer.numChildren; i++)
			{
				box = contentLayer.getChildAt(i) as Box;
				if(box.hitTestPoint(p.x,p.y)) elementOnTop=box;
			}
						
			if(elementOnTop!=null) hoverElement(elementOnTop);
			
			Binder.suspend = true;
			for each (var miscToken in miscTokens )
			{
				miscToken['reveal'].apply();
			}
			showLayers();
		}

		//
		//
		//
		public function exitEditMode()
		{
			if(!editing) return;
			editing = false;
			
			Clock.start();
			Metronome.start();			
			
			unhoverAllElements();
			hideElementTokens();
			selectedElement = null;
			//hideCards();
			
			TweenMax.to(backgroundLayer,.5,{tint:0xffffff});
			TweenMax.to(contentLayer,0,{colorTransform:{color:0xbbbbbb,tintAmount:0}});

			for each(var card:PropertiesCard in cards)
			{
				card.hide();
			}
			setTimeout( function(){Binder.suspend = false;},500);

			for each (var miscToken in miscTokens )
			{
				miscToken['hide'].apply();
			}
			hideLayers();
		}		

		//
		//
		//	
		public function showElementTokens():void
		{
			var et 		: ElementToken;
			var aabb 	: Rectangle;
			for each(var box:Box in elements)
			{
				
				aabb = box.getBounds(selectionLayer);
				et = new ElementToken(box,box==selectedElement);
				et.x = aabb.x + aabb.width/2;
				et.y = aabb.y + aabb.height/2
				tokenLayer.addChild(et);
				et.reveal();
				elementTokens.push(et);
			}
		}
		
		//
		//
		//	
		public function hideElementTokens():void
		{
			for each(var et in elementTokens)
			{
				et.hide();
			}
		}
		
		//
		//		
		//	Hilight a specific clip. (This will get more difficult when things are rotated)
		public function hoverElement(b:Box):void
		{			
			if(hoveredElementOverlays[b] != undefined) return;
			
			var hoverClip = new Sprite();			
			var overlay : Sprite = new Sprite();
			var aabb		= b.getBounds(selectionLayer);
				
			if(b.color==0x000000)
			{
				overlay.blendMode = BlendMode.MULTIPLY;
				overlay.filters = [new GlowFilter(0x000000,.3,15,15,2,3,true)];
				overlay.graphics.beginFill(0x648691,1);				
			}
			else
			{

				overlay.filters = [new GlowFilter(0x000000,.3,15,15,2,3,true)];
				overlay.blendMode = BlendMode.SCREEN;
				overlay.graphics.beginFill(0x9ACFDB,1);
			}
			overlay.graphics.drawRect(aabb.x,aabb.y,aabb.width,aabb.height);
			overlay.graphics.endFill();			
			overlay.alpha = .5;
			
			var borderClip : Sprite = new Sprite();
			borderClip.graphics.lineStyle(1,0xA7E7EA);
			borderClip.graphics.drawRect(aabb.x,aabb.y,aabb.width,aabb.height);
			borderClip.filters = [new DropShadowFilter(1,90,0x000000,1,3,3,1,3)];
			
			hoverClip.addChild(overlay);
			hoverClip.addChild(borderClip);
			selectionLayer.addChild(hoverClip);
			
//			trace(aabb);
			
			hoveredElementOverlays[b] = hoverClip;
		}
		
		//
		//
		//
		public function unhoverElement(b:Box):void
		{
			if(hoveredElementOverlays[b] == undefined) return;
			
			selectionLayer.removeChild(hoveredElementOverlays[b]);
			hoveredElementOverlays[b] = undefined;

		}
		
		//
		//		Clear any drawing and any clips used for hilighting selections
		// 
		public function unhoverAllElements():void
		{
			selectionLayer.graphics.clear();
			
			for( var i :int = selectionLayer.numChildren; i > 0; i--)
			{
				selectionLayer.removeChildAt(i-1);
			}
			hoveredElementOverlays = new Dictionary();
		}
		
		//
		//
		//
		public function showElementProperties(element:Object)
		{
//			trace("TableTop::showElementProperties()");
			var pCard = new PropertiesCard();

			tokenLayer.addChild(pCard);
			
			if(element is Box) pCard.init(element,'x:x position,y:y position,Left:Left,Right:Right,Top:Top,Bottom:Bottom,rotation');
			else if(element is Class && element.instance is Clock) pCard.init(element,'time,milliseconds,fractionSeconds:fraction seconds,seconds:whole seconds,minutes,hours');
			else if(element is Class && element.instance is Metronome) pCard.init(element,'totalBeats:beats,quarterNotes,halfnotes');
			
			pCard.x = mouseX - pCard.width/2;
			pCard.y = mouseY + 20;

			pCard.reveal();

			activeCard = pCard;
			cards.push(pCard);
			
		}
		

		//
		//
		//
		//		EVENT HANDLERS
		//
		//
		//
		
		//
		//	Basic handlers
		//
		public function handleElementDownCapture(e:MouseEvent)
		{
			if(!editing  || !(e.target is Box)) return;
			e.stopPropagation();
			handleElementDown(e);
		}

		//
		//
		//
		public function handleMouseOverCapture(e:MouseEvent):void
		{
			// if dragging a token, don't let other tokens get rollOver events...
			if(e.target is PropertyToken && dragSource != null)
			{
//				trace("TableTop::handleMouseOverCapture(), kill event");
				e.stopPropagation();
			}
			/*else if(e.target is Box && editing )
			{
				e.stopPropagation();
				hoverElement(e.target as Box);
			}*/
		}
		
		//
		//
		//
		public function handleElementDown(e:Event)
		{
//			trace("TableTop::handleElementDown()");
			
			if(!editing) return;

			if(! KeyHelper.isDown(Keyboard.SHIFT) )
			{
				if(activeCard != null) activeCard.hide();
			}

			//TweenMax.to(this,.25,{z:75});
			if(selectedElement!=null) unhoverElement(selectedElement);
			
			selectedElement = e.target as Box;

			showElementProperties(selectedElement);

			//pCard.z = -100;
			//TweenMax.to(pCard,.25,{z:-75});
		}
				
		public function handleElementOver(e:MouseEvent):void
		{
			if(!editing || dragSelecting || e.buttonDown) return;
			hoverElement(e.target as Box);
		}
		
		public function handleElementOut(e:MouseEvent):void
		{
			if(!editing || selectedElement == e.target || e.relatedObject is ElementToken || e.relatedObject is PropertiesCard ||e.relatedObject is PropertyToken) return;
			unhoverElement(e.target as Box);
//			trace(e.relatedObject);
		}
		
		//
		//		Drag and drop handlers
		//
		
		public function handleGrab(e:DragDropEvent)
		{
			dragging = true;
			dragSource = e.target as DragButton;
			
			// get ther get the representation of the content...
			dragSourceRepresentation = dragSource.getDraggableContentRepresentation();

			var p = globalToLocal(dragSource.localToGlobal(new Point(0,0)));
			dragSourceRepresentation.x = mouseX - dragSourceRepresentation.width/2;		//p.x;
			dragSourceRepresentation.y = mouseY - dragSourceRepresentation.height/2;	//p.y;
			
			dragSourceCard = activeCard;
			
			dragSourceLayer.addChild(dragSourceRepresentation);			
//			Binder.drag(dragSourceRepresentation); 
		}

		public function handleDrop(e:DragDropEvent)
		{			
			
			// and the rest...
			if(currentDropTarget!=null)
			{
				
				// is actually a 'PLACE' event
				
				e.stopPropagation();
				
				var droppedToken : PropertyToken = (e.target as PropertyToken);
				droppedToken.animatePlace();
				currentDropTarget.animateRecieve();	
//				dispatchEvent(new DragDropEvent...); // how to dispatch event to those below listening?
					// maybe a modified drop event makes it down to he dragged token clip with a ref to the target,
					// then it generates a DragDropEvent.PLACE event?...
					// the currentDropTarget should be lookig for this anyhow.
					// maybe the event should be grabbed later? By the card?...
					
				// create mapping				
				//trace((currentDropTarget as PropertyToken).targetObject,(currentDropTarget as PropertyToken).targetProp,droppedToken.targetObject,droppedToken.targetProp);
				
				trace("TableTop::handleDrop()",(currentDropTarget as PropertyToken).targetProp);
				var mapping;
				if((currentDropTarget as PropertyToken).targetObject == Clock)
				{
					if(currentDropTargetArea =='left' ) return;					
					switch((currentDropTarget as PropertyToken).targetProp)
					{
						case 'time':
							mapping = '/2';
							break;
						
						/*case 'milliseconds':
							mapping = '*1';
							break;*/
							
						case 'seconds':
							mapping = '*10';
							break;
							
						case 'minutes':
							mapping = '*10';
							break;
							
					}
				}
				else if((currentDropTarget as PropertyToken).targetObject == Metronome)
				{
					if(currentDropTargetArea =='left' ) return;
					mapping = '*10';				
				}
				
				if(currentDropTargetArea == 'left') Binder.bindChanges(droppedToken.targetObject,droppedToken.targetProp,(currentDropTarget as PropertyToken).targetObject,(currentDropTarget as PropertyToken).targetProp,mapping);
				else if (currentDropTargetArea == 'right') Binder.bindChanges((currentDropTarget as PropertyToken).targetObject,(currentDropTarget as PropertyToken).targetProp,droppedToken.targetObject,droppedToken.targetProp,mapping);	
				
				currentDropTarget = null;
				currentDropTargetArea = null;
				
				activeCard.unPreviewDropTarget();
				
				dragSourceLayer.removeChild(dragSourceRepresentation);
			}			
			else
			{
				// is a 'drop' ie. a place in invalid position, or a rejected place.
				// show card if hidden			
				/*
				var originCard =  dragSource.parent.parent as PropertiesCard	// HACK

				// if card isn't under the cursor, then hide afterwards			
				if(originCard.hidden) originCard.reveal();
				var p = new Point(mouseX,mouseY);
					p = localToGlobal(p);
				if(!originCard.hitTestPoint(p.x,p.y)) setTimeout(originCard.hide,500);
				*/				
				
				// put drag content back in dragSource clip
//				var soureceElementBounds = dragSourceCard.targetEntity.getBounds(dragSourceLayer);				
//				TweenLite.to(dragSourceRepresentation,.5,{alpha:0/*,x:soureceElementBounds.x+soureceElementBounds.width/2,y:soureceElementBounds.x+soureceElementBounds.height/2,ease:Quint.easeOut*/});				
//				setTimeout(dragSourceLayer.removeChild, 501,dragSourceRepresentation);				
								
				dragSourceLayer.removeChild(dragSourceRepresentation);
				
			}
													
			// other
			hideElementTokens();

			// clean up
			dragging = false;
			dragSource = null;
			
//			trace("PropertyTokenTest::handleDrop()");
		}

		// when a token is dragged out of a card...
		// maybe should activate when a card hides?... too much lag?
		public function handleDelayedTokenDragOutFromCard(e:PropertiesCardEvent)
		{
			// reveal entity tokens...
//			trace("TableTop::handleDelayedTokenDragOutFromCard()");
//			unhoverElement(e.target.selectedElement);
			unhoverAllElements();
			showElementTokens();
		}

		public function handlePropertiesCardHide(e:PropertiesCardEvent):void
		{
//			trace("TableTop::handlePropertiesCardHide()");			
			if(editing)
			{
//				trace('		',e.target.targetEntity,selectedElement);
//				if(e.target.targetEntity != selectedElement) unhoverElement(selectedElement);
				return;
			} 

			tokenLayer.removeChild(e.target as DisplayObject);
			for(var i : uint = 0; i < cards.length; i++)
			{
				if(cards[i]==e.target)
				{
					cards.splice(i,1);
					break;
				}
			}			

			if(activeCard == e.target) activeCard = null;
		}

		public function handleElementTokenOver(e:MouseEvent)
		{	
			
			if(selectedElement is Box) hoverElement(selectedElement);
			if(e.target['targetElement'] is Box) hoverElement((e.target as ElementToken).targetElement as Box);


			hideElementTokens();		
			// if dragging a property token from the same source as this element token...
			if(dragSourceCard != null && e.target['targetElement'] == dragSourceCard.targetEntity)
			{
				dragSourceCard.reveal();
			}
			else showElementProperties(e.target['targetElement']); // <- slop.

		}

		public function handleElementTokenHide(e:Event)
		{
			if(editing) return;
			tokenLayer.removeChild(e.target as DisplayObject);
			for(var i : uint = 0; i < elementTokens.length; i++)
			{
				if(elementTokens[i]==e.target)
				{
					elementTokens.splice(i,1);
					return;
				}
			}
		}
		
		public function handleTokenRelease(e)
		{
//			trace("TableTop::handleTokenRelease()");
		}
		
		//  maybe we should have a ElementTokenDragOver... ?...
		public function handleDragOver(e1,e2):void
		{
			/* if element token
				hideElementTokens()
				show card for target
				
			else if PropertyToken
				// animateEclipse();
			*/
		}
		
		
		//
		//
		//
		
		
		public function handleKeydown(e:KeyboardEvent):void
		{
			// constrain if dragging element and key is shift	
			// nudge if arrow keys
		}
		
		public function handleKeyUp(e:KeyboardEvent):void
		{
			// constrain if dragging element and key is shift			
			// nudge if arrow keys
		}
		
		
		//
		//
		//
		public function handleBackgroundDown(e:Event):void
		{
			// clicking on page?... maybe listen to the page? send an event?
//			trace("TableTop::handleBackgroundDown()");
			// should probably only be able to make a selection if a modifier key is being pressed...
			if(!editing) return;
			dragSelecting = true;
			startDragX = mouseX;
			startDragY = mouseY;			
			enterEditMode();
		}
		
		public function handleMouseUp(e:Event):void
		{
//			trace("TableTop::handleUp()");
			if(dragSelecting)
			{
				// select a buch of things
				dragSelecting = false;
				foregroundLayer.graphics.clear();
//				exitEditMode();
			}
		}
		
		//
		//
		//
		
		public function handleMouseMove(e:MouseEvent):void
		{			
			if(editing)
			{
				e.updateAfterEvent();
								
				if(dragSelecting)
				{
					// put this into some kind of redraw function?
					foregroundLayer.graphics.clear();
					foregroundLayer.graphics.lineStyle(1,0xA7E7EA);
					foregroundLayer.graphics.drawRect(startDragX,startDragY,mouseX-startDragX,mouseY-startDragY);

					// check for selected elements
					// can't have negative sizes :(
					var selectionRectangle = new Rectangle(	Math.min(startDragX,mouseX),
															Math.min(startDragY,mouseY),
															Math.abs(mouseX-startDragX),
                                                            Math.abs(mouseY-startDragY));

					for(var i : uint = 0; i < elements.length; i++)
					{
						var box = (elements[i] as Box);

						if(selectionRectangle.intersects(box.getRect(this)))
						{
							hoverElement(box);
						}
						else
						{
							unhoverElement(box);
						}
					}
					
				}
				
				// this is a bit of an event loop and should probably be pared down to just find and dispatch events
				// except... can't pass down revised events :(
				if(dragSource == null) return;	
				
				dragSourceRepresentation.x = mouseX - dragSourceRepresentation.width/2;		
				dragSourceRepresentation.y = mouseY - dragSourceRepresentation.height/2;

				// if we were pointing at something but now we're not pointing at it...
				if(currentDropTarget != null && !(currentDropTarget as Sprite).hitTestPoint(stage.mouseX,stage.mouseY))
				{
					currentDropTarget.animateUnEclipsed();
					dragSource.animateDraggedOut();
					activeCard.unPreviewDropTarget();	

					dragSourceRepresentation.alpha = 1;
					dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_OUT));
					currentDropTarget = null;
					currentDropTargetArea = null;

				}

				// find out if we're pointing at something...
				
				cardLoop : for each(var card:PropertiesCard in cards)
				{
					if(card.hidden) continue;
										
					tokenLoop : for each(var token:PropertyToken in card.tokens)
					{				
						
						// if we're comparing a token to itself
						if(token == dragSource) continue;
						
						// if we weren't pointing at something, and now we are
						if(currentDropTarget==null && token.hitTestPoint(stage.mouseX,stage.mouseY))
						{				

								currentDropTarget = token;
								currentDropTarget.animateEclipsed();
								dragSource.animateDraggedOver();
								//dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_OVER)); // probably should be triggering animation...
								// why not really? too much fuss to implement in buttons?
								break cardLoop;
						}
					}
				}
				
				// if we're dragging over something
				if(currentDropTarget != null)
				{
					
					var mx = (currentDropTarget as Sprite).mouseX;
					var newTargetDropArea : String;
					
					// ... find out what part we're dragging over...
					var targetWidth = (currentDropTarget as Sprite).width

					/*
					if(mx < targetWidth/3) 			newTargetDropArea = 'left';
					else if(mx < targetWidth/3*2) 	newTargetDropArea = 'center';
					else 							newTargetDropArea = 'right';
					*/
					
					if(mx < targetWidth/2) 			newTargetDropArea = 'left';
					else 						 	newTargetDropArea = 'right';
					
					// if the new area is different than the old area...
					if(newTargetDropArea != currentDropTargetArea)
					{
						activeCard.unPreviewDropTarget();
						activeCard.previewDropTarget(currentDropTarget as PropertyToken, newTargetDropArea, dragSource as PropertyToken);
						
						currentDropTargetArea = newTargetDropArea;
						
						dragSourceRepresentation.alpha = 0;
					}										
				}
			}
		}
		
	}
}