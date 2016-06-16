package net.manipulus.UI
{
	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	import net.manipulus.UI.*;
	
	public class Main extends Sprite
	{

		// public var tableTop : TableTop

//		var activeArea			: Sprite;
//		var workSpace 			: ActiveArea;
		var backgroundLayer		: Sprite; 
		var hudLayer			: Sprite;
				
		var inHand				: Object;	// .... ? ....
		
		var isKeyDown			: Boolean = false;
		/*
		Move'ns
		
			move into work space (slip into work cursor)
			move out of work space (slip out of work cursor / or vice versa!)
			move into tool area
		
		Presses
		
			press add box
			press existing box				
			press active space
		
		
		Dragging states / what's in your hand
			
			new box
			existing box
			property token token
			bag (selection box)
			
		
		On release
		
			release new box in workspace
			release new box not in workspace
			
			release existing box in work space
			release existing box not in work space... (pasteboard? delete?)
		
			
		
		*/
		
		function Main()
		{
			init();					
		}
		
		function init()
		{
//			backgroundLayer  = new Sprite();			
//            tableTop 		 = new ActiveArea();
//			hudLayer  		 = new Sprite();

//			addChild(backgroundLayer);
//			addChild(workSpace);
//			addChild(hudLayer);			
			
//			workSpace.x = 200;
//			workSpace.y = 200;
						
//			workSpace.init();
			
			// add event listeners...
			addEventListener('NewElementReleased',handleNewElementReleased);
			addEventListener('NewElementHover',handleNewElementHover);
			
			KeyHelper.init(stage);
			KeyHelper.addEventListener(KeyboardEvent.KEY_DOWN,handleSingleKeyDown);
			KeyHelper.addEventListener(KeyboardEvent.KEY_UP,handleKeyUp);
			
			blackBoxButton.newClipData = 0;
			whiteBoxButton.newClipData = 0xffffff;
			
			//
			for(var i : uint = 0; i < 20; i++)
			{
				tableTop.addBox(Math.random()*500,Math.random()*500,(Math.round(Math.random()))*0xffffff)
			}
			
		}
				
		
		function refresh()
		{
			// arrange
		}
		
		// elmt
		public function displayPropertiesOfElement(elmt:Sprite):void
		{
			
		}
		
		//---------------------------------------
		// EVENT HANDLERS
		//---------------------------------------
		
		public function handleNewElementHover(e:Event):void
		{
			addChild(e.target as Sprite)
		}
		
		public function handleNewElementReleased(e:Event):void
		{
			// where was it dropped?
			if(tableTop.hitTestPoint(mouseX,mouseY))
			{
				tableTop.addBox(tableTop.mouseX,tableTop.mouseY,(e.target as ElementButton).newClipData);
				(e.target as ElementButton).handleElementPlaced();
			}
			else
			{
				(e.target as ElementButton).handleElementDropped();
			}
		}
		
		
		public function handleElementSelected(e:Event):void
		{
//			displayPropertiesOfElement(e.currentTarget);
		}
		
		
		//
		//	Basic event handlers  (which should come first, generic or the interpreted ones?...)
		//
		
		function handleMouseRelease()
		{
			// are dragging?
			// are release in 
		}
		
		function handleMouseDown()
		{
			
		}
		
		// Using com.manipulus.UI.KeyHelper to take care of — avoid — 'key repeat'.
		public function handleSingleKeyDown(e:KeyboardEvent):void
		{
			//trace('down: ' + e.keyCode);			
			var keyPressed = String.fromCharCode(e.keyCode);

			if(e.keyCode == Keyboard.SPACE)
			{
				tableTop.showLayers();	
			}
			else if( keyPressed == 'E')
			{
				tableTop.enterEditMode();
			}
			
		}
		
		public function handleKeyUp(e:KeyboardEvent):void
		{
			//trace('up: ' + e.keyCode);		
			var keyPressed = String.fromCharCode(e.keyCode);	
			if(e.keyCode == Keyboard.SPACE )
			{
				tableTop.hideLayers();	
			}
			else if( keyPressed == 'E')
			{
				tableTop.exitEditMode();
			}
			
		}
		
		function handleItemPress()
		{
			
		}
		
		function handleEnterFrame()
		{
			// check to see if we've moved into a new area...
		}
		
		
		
		
	}
	
}