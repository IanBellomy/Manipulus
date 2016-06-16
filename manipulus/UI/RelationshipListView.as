package net.manipulus.UI
{	
	
	import flash.display.*;
	import net.manipulus.*;
	import flash.utils.*;
	import flash.events.*;
	import flash.text.*;
		
	public class RelationshipListView extends Sprite
	{

	
		public function RelationshipListView()
		{
			super();
			Binder.addEventListener(RelationshipEvent.MAPPING_CREATED,handleRelationshipCreated);
			Binder.addEventListener(RelationshipEvent.MAPPING_REMOVED,handleRelationshipRemoved);
			addEventListener(Event.ENTER_FRAME,refresh);
			
			var styleInactive:StyleSheet = new StyleSheet(); 
			var styleObj:Object = new Object(); 
				styleObj.color = "#000000"; 
				styleInactive.setStyle(".number", {color:"#00ffff"}); 
				styleInactive.setStyle(".inactive", styleObj); 
			
			driversText.styleSheet = styleInactive;
			 drivenText.styleSheet = styleInactive;
			mappingText.styleSheet = styleInactive;
			
		}
		
		public function handleRelationshipCreated(event:RelationshipEvent):void
		{			
			refresh();
			/*var driverName:String = (event.mapping.driver.object is Stage)? 'Stage' : event.mapping.driver.object.name;
			var mappingString :String = "Binder.map("+driverName+",'"+event.mapping.driver.property+"',"+event.mapping.driven.object.name+",'"+event.mapping.driven.property+"');";			
			textClip.text += '\n'+mappingString;*/
		}
		
		public function handleRelationshipRemoved(event:RelationshipEvent):void
		{
			refresh();
		}
		
		
		public function refresh(e:Event = null):void
		{
			/*var mappingString:String = '';
			var dependencies : Dictionary = Binder.dependencies;
			var mapping :Relationship;
			for each (var arrayOfRelationships:Object in dependencies)
			{
				for each( mapping in arrayOfRelationships)
				{					
					var driverName:String = nameFor(mapping.driver.object);
					var drivenName:String = nameFor(mapping.driven.object); // unless function, check for desription?
					var mappingType = (mapping.absolute)? 'bind' : 'bindChanges'
					mappingString+= "\n"+mappingType+"("+driverName+",'"+mapping.driver.property+"',"+drivenName+",'"+mapping.driven.property+"');";	// Actionscript
					//mappingString += '\n'+mappingType+driverName+'.'+mapping.driver.property +' => '+mappingType+drivenName+'.'+mapping.driven.property;	// shorthand
				}	
			}
			textClip.text = '\n'+mappingString;*/
			
			driversText.text = '';
			drivenText.text = '';

			var str1 = '';
		 	var str2 = '';
		 	var str3 = '';
		
			var cssClass = '';
			
			for each(var key  in Binder.inputs)
			{
				var n = 0;
				for each(var rel in Binder.dependencies[key])
				{
					//if(rel.driver.object == stage) continue;
					cssClass= (rel.active)?'active':'inactive';
					if(n == 0) str1 += '<span class="'+/*cssClass+*/ '">'+key+ ' <span class="number">' + Math.floor(rel.driver.valueOf()) +'</span></span>\n';
					else str1+='\n';
					
					if(rel.active) str2 += '<span class="'+cssClass+ '">'+'<span class="number">' + Math.floor(rel.driven.valueOf()) +'</span> ' + rel.driven +'</span>\n';
					else str2 += '<span class="'+cssClass+ '">'+'<span class="">' + Math.floor(rel.driven.valueOf()) +'</span> ' + rel.driven +'</span>\n';
					str3 += ((rel.active)?'->':'')+'\n';
					n++;
				}
				str1+='\n';
				str2+='\n';
				str3+='\n';								
			}
			

			
			
			for(key in Binder.dependencies)
			{				
				
				if(Binder.inputs.indexOf(key) != -1) continue;
				for each(rel in Binder.dependencies[key])
				{
					//if(rel.driver.object == stage) continue;
					str1 += '<span class="'+/*cssClass+*/ '">'+key+ ' <span class="number">' + Math.floor(rel.driver.valueOf()) +'</span></span>\n';
										
					if(rel.active) str2 += '<span class="'+cssClass+ '">'+'<span class="number">' + Math.floor(rel.driven.valueOf()) +'</span> ' + rel.driven +'</span>\n';
					else str2 += '<span class="'+cssClass+ '">'+'<span class="">' + Math.floor(rel.driven.valueOf()) +'</span> ' + rel.driven +'</span>\n';
					str3 += ((rel.active)?'->':'')+'\n';

				}

			}


			driversText.htmlText = str1;
			drivenText.htmlText  = str2;
			mappingText.htmlText = str3;
			
			
			driversText.alpha = 1-int(Binder.suspend)*.8;
			drivenText.alpha  = 1-int(Binder.suspend)*.8;
			mappingText.alpha = 1-int(Binder.suspend)*.8;
			
		}
	
		public function nameFor(something:Object):String
		{
//			if(something['parent']!=null &&  something['parent'] is stage) return 'this';
			if(something is Stage) return 'stage';
			else if(something is Function) return '{formula...}';
			else if(something is DisplayObject) return something.name;			
			else if(something is Interactive) return something.following.name;
			if(something is Set)
			{
				var str = '[';
				for(var i = 0; i < (something as Set).length; i++)
				{					
					str += nameFor(something[i]) + ',';
				}
				str = str.slice(0,-1) + ']';
				return str;
			}
			else return something.toString();
		}
	
	}
}