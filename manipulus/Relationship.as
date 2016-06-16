/*

	seems like all this shoudl do is put one value into another.
	except... some values don't exist...
	
		like...
		
			deltaV
			previousV
			velocityV
			distanceBetweenV1andV2
			angleBetweenP1andP2
			
		these values need to be created internally...
		
		
		// property of a property... metaProperty...
		
		
		possibleMetaProperties = [
									'changeInValue',
									'previousValue_N',
									'velocity',
									'acceleration',
									'mapping'			// not really...
								]
	
		
		
		getMetaProp(obj,prop,metaProp)	: Number
		setMetaProp(obj,prop,metaProp)
		
		// how do we track these meta properties then?
		// how do we set them?
		
			// called when something has changed... when something external to the system has changed
			// input or time
			mapper.update()
			{
				// update metaProperties of any external values (watched values)...
				// propigate these changes through the system...
					// ie. 	If there are any mappings with these as drivers
					// 		push the value from the input to the output.
					//		then, check for constraints?
					//		then, update any metaProperties of the output...
					//		then, check for any dependencies of the output
					//		then, check for any dependencies of the output's values?
				
			}
		
		// 
			MetaProp.setDelta(v)
			{
				if(timeStamp == Binder.getCurrentTime()) return;
				
				obj['prop'] += v;
				
				timeStamp = Binder.getCurrentTime();	// 
			}
		
		// maybe it's just an 'advancedProperty'
		
			clip.x_change
			clip.touched
			clip.x_previousValue
			
			clip.x_previousValue_10ms // the value of 'x' 10 ms ago...
			
			Binder.bindChanges(clip,'deltaX',clip2,'deltaX');
				// creates references for clip.deltaX and clip2.deltaX, then maps them to one another.
				
			// these extra properties seem to watch and be modified by others that may be problematic...
			// what if you did...
			
				Binder.bindChanges(clip,'deltaX',clip,'x'); // would it just say 'illegal mapping'
		
		//* 
		
			if object[prop] == undefined;
			crea
		
		
		// map to delta
		
			ref = new TemporalProperty(object,property); // Watcher, Tracker...
			
			metaProperties.push(ref);	// keep track of them...			
			
			Binder.extras = new Dictionary();
			Binder.extras[driverObject] = new Dictionary();
			Binder.extras[driverObject]['changeInValue'] = Reference;

			driver = new Reference(Binder.extras[driverObject],'changeInValue');
			driven = new Reference(drivenObject,drivenProperty);
			
			mapping = new Relationship(driver,driven);
		
		
			/*
			mapping.update()
			{
				driver.value = mapping.apply(driven.value);
			}
			*/
			
			
/*		
		Values aceesible to a mapping function, accessible to a reference?
		
		INPUT_CHANGE
		INPUT_VALUE
		PREVIOUS_INPUT_VALUE(distance)
		INPUT_VELOCITY	
	
		OUTPUT_CHANGE
		OUTPUT_VALUE
		OUTPUT_VELOCTY
		
		
		
		//default is
		
		OUTPUT_CHANGE = fn(INPUT_CHANGE);

1000/(bpm/60)

100/(2/1)

50/2 25

*/

package net.manipulus
{

	import flash.display.*;
	import flash.text.TextField;
	import net.manipulus.Binder
		

	public class Relationship
	{
		public var driver			: Reference;
		public var driven			: Reference;
		public var mappingFunction	: Function;
		public var delay			: uint		= 0;
		public var suspend			: Boolean = false;
		public var absolute			: Boolean = false;
		private var lastTimeStamp	: uint;
		
		public function Relationship(driver_:Reference,driven_:Reference,mappingFunction_:Object = null,delay_:int=0)
		{
			
			lastTimeStamp = Binder.currentTimeStamp;
			
			driver	= driver_;
			driven	= driven_;	
			
			delay	= delay_;
			
			if(mappingFunction_ == null)
			{
				mappingFunction = function(inputValue:Number):Number
				{
					return inputValue;
				}
			}
			else if (mappingFunction_ is Number)
			{
				mappingFunction = function(inputValue:Number):Number
				{
					return inputValue * this['multiplier'];					
				}
				mappingFunction['multiplier'] = mappingFunction_;
			}
			else if (mappingFunction_ is String)
			{
				mappingFunction = parseRelationshipString(mappingFunction_ as String);
			}
			else
			{
				mappingFunction = mappingFunction_ as Function;
			} 
			
		}
		
		public function isTo(obj:Object,property:String=null):Boolean
		{
			return driven.isTo(obj,property);
		}
		
		public function isFrom(obj:Object,property:String=null):Boolean
		{
			return driver.isTo(obj,property);
		}
		
		public function resolve(timeStamp:uint):void
		{

			//trace("Relationship::resolve()"+driver.object);
			
			
			if(driven.object is Interactive)// && driven.object['name'] == 'controlBox')// && driven.property == 'y')			
			{
				trace(driven.object.name);
				//trace('asdf');
				//trace("		"+driver.object+'::' + driver.property +':'+driver.object[driver.property]+' -> ' +driven.object.name+'::'+driven.property);
			}
						
			if(lastTimeStamp == timeStamp || suspend) return;
			
			
			if(delay == 0)
			{				
				
				if(absolute) 	driven.object[driven.property] = mappingFunction.apply( mappingFunction, [driver.targetValue] );
				else 			driven.object[driven.property] += mappingFunction.apply( mappingFunction, [driver.changeInValue] );
			}
			else
			{			
				
				if(absolute)	driven.object[driven.property] = mappingFunction.apply( mappingFunction, [driver.getValueAtTime(timeStamp-delay)] );
				else 			driven.object[driven.property] += mappingFunction.apply( mappingFunction, [driver.changeInValueBetweenTimes(lastTimeStamp-delay, timeStamp-delay)] );
			}
						
			//trace("		now: " +driven.object[driven.property]);
			lastTimeStamp = timeStamp;
		}		
		
		public function set active(val:Boolean):void
		{
			suspend = !val;
		}
		
		public function get active():Boolean
		{
			return !suspend;
		}
		
		public function ifIs(object:Object,prop:String):Relationship
		{
			if(prop=='pressed' && object is TextField) suspend = false;
			else suspend = !object[prop];
			return Binder.bind(object,prop,this,'suspend',function(input){return !input;});
		}				
		
		public function ifIsNot(object:Object,prop:String):Relationship
		{
			if(prop=='pressed' && object is TextField) suspend = true;
			else suspend = object[prop];
			return Binder.bind(object,prop,this,'suspend');
		}		
		
		
		public function exception(object:Object,prop:String):Relationship
		{
			suspend = object[prop];
			return Binder.bind(object,prop,this,'suspend');
		}

		public function clause(object:Object,prop:String):Relationship
		{
			return ifIs(object,prop);
		}

		
		//
		//
		// Relationship parsing function(s)
		//
		//
		/*
			
			"*10"
			"/10"
			"+10"
			"-10"
			"^2"
			">10"
			"<10"			
			"==10"			
			
			"%10"	repeat?	This is a 'constraint', no?	
			"|10"	sample?	ditto?		
		
			["*",o1,"property"] ...
						
		*/
				
		function parseRelationshipString(mapping:String):Function
		{
			var fn;
			
			switch (mapping.charAt(0))
			{
				case '*':
					fn = function(input){ return input*arguments.callee.multiplier};
					fn.multiplier = Number(mapping.substr(1));					
					break;
					
				case '/':
					fn = function(input){ return input*arguments.callee.multiplier};
					fn.multiplier = 1/Number(mapping.substr(1));
					break;
				
				case '%':
					fn = function(input){ return input%arguments.callee.multiplier};
					fn.multiplier = Number(mapping.substr(1));
					break;
				
				case '+':
					fn = function(input){ return input+arguments.callee.addition};
					fn.addition = Number(mapping.substr(1));
					if(isNaN(fn.addition)) fn.addition = mapping.substr(1);
					break;
				
				case '-':
					fn = function(input){ return input+arguments.callee.addition};
					fn.addition = -Number(mapping.substr(1));
					break;
					
				case '^':
					fn = function(input){ return input+arguments.callee.power};
					fn.power = Number(mapping.substr(1));
					break;
					
				case '>':
					fn = function(input){ return input > arguments.callee.comparison};
					fn.comparison = Number(mapping.substr(1));				
					break;
					
				case '<':
					fn = function(input){ return input < arguments.callee.comparison};
					fn.comparison = Number(mapping.substr(1));
					break;
					
				case '=': // '=='
					fn = function(input){ return input == arguments.callee.comparison};
					fn.comparison = Number(mapping.substr(1));
					break;			
				
				case 'f':
					// floor
					
					fn = function(input){ return Math.floor(input*Math.pow(10,arguments.callee.places))/Math.pow(10,arguments.callee.places)};
					fn.places = Number(mapping.split(':')[1]);
					if(isNaN(fn.places)) fn.places = 0;
					break;
				
				case 'e': //"eased:n"
					fn = function(targetValue)
					{
						this['target'] = targetValue;
						return this['actualReference']+(this['target'] - this['actualReference'])/Math.max(1,this['slowness']);		
					}
					fn.target = driven.targetValue;
					fn.actualReference = driven;
					
					var slowness = Number(mapping.split(':')[1]);
					fn.slowness = (isNaN(slowness))? 10:slowness;
					
					break;
				
				default:
					// look for  n,n (constraint)
					// 
					
							
			}
			
			fn.toString = function()
			{
				return "mapping";
			}
			
			return fn;
			
		}
		
		public function toString():String
		{
			return "("+driver+" -> "+driven+")";
		}
	
		
	}
}
