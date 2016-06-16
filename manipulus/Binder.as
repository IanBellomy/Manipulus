/**
*		
*		
* Binder class
* Sharp mapping, instant propigation!
*				
*
*	
* Need to make sure to update all stragglers. (This will help catch instances where a setter that effects another will still propigate)
* lastly... re-implement latency... and mapping...				
*
*
*			
*
*
*/

package net.manipulus
{

	import flash.events.*;
	import flash.display.*;
	import flash.utils.*;
	
	public class Binder extends EventDispatcher
	{
		
		public static var suspend 		: Boolean = false;
		
		protected static var _instance	: Binder
		
		protected var inputs			: Array;		
		protected var dependencies 		: Dictionary; // !!
		protected var currentTimeStamp	: uint;
		protected var _stage			: Stage;
		protected var externalProperties: Array;

		public var interactives		: Array;	

//		protected var mappings			: Dictionary;
	
		function Binder(stage_:Stage = null)
		{
			if(Binder._instance != null) throw new Error('Binder is a singleton class, new instances can not be crated.');							
			
			dependencies     = new Dictionary();			
			interactives     = new Array();
//			mappings       	 = new Dictionary();
			inputs           = new Array();
			currentTimeStamp = new Date().getTime();

			externalProperties = ['mouseX','mouseY','touched','pressed'];
			
			if(stage_!=null) stage = stage_;

		}
		
		public function set stage(stage_:Stage):void
		{
			if(_stage==stage_) return;
			_stage = stage_;
			// maybe add these as needed?
			_stage.addEventListener(MouseEvent.MOUSE_MOVE,handleExternalEvent);
			_stage.addEventListener(MouseEvent.MOUSE_DOWN,handleExternalEvent);
			_stage.addEventListener(MouseEvent.MOUSE_UP  ,handleExternalEvent);
			_stage.addEventListener(Event.ENTER_FRAME	,Binder.update);
//			_stage.addEventListener(KeyboardEvent.KEY_DOWN,handleExternalEvent);	
//			_stage.addEventListener(KeyboardEvent.KEY_UP,handleExternalEvent);	

		}
		
		public function get stage():Stage
		{
			return _stage;
		}
		
		//
		//	(Would be really nice to get around this...
		//
		
		public static function init(stage_:Stage)
		{
			if(_instance!=null) _instance.stage = stage_;
			else _instance = new Binder(stage_);
			
			Cursor.init(stage_);
			
//			stage['DM'] = Binder.bindChanges;
//			stage['AM'] = Binder.bind;
		}
		
		//
		//	SINGLETON GETTERS
		//
		
		private static function get instance():Binder
		{
			
			if(_instance == null)
			{
//				trace("Binder::get instance(): ERROR : Binder.init(stage:Stage) must be called before it can be used..."); 
				_instance = new Binder();
//				return null;
			}
			return _instance;
		}

		//
		//	Wrappers for instance properties... because I didn't want to put '_instance.' in front of them all... TODO: do that...
		//
		
		public static function get dependencies():Dictionary
		{
			return instance.dependencies;
		}
		public static function get stage():Stage
		{
			return instance._stage;
		}		
		public static function get inputs():Array
		{
			return instance.inputs;
		}
		public static function get currentTimeStamp():uint
		{
			return instance.currentTimeStamp;
		}
		public static function set currentTimeStamp(val:uint):void
		{
			instance.currentTimeStamp = val;
		}
		
		public static function get externalProperties():Array
		{
			return instance.externalProperties;
		}	
		
		//
		//	SINGLETON EVENT DISPATCHER WRAPPERS
		//
		
		public static function addEventListener(...arg)
		{
			return instance.addEventListener.apply(instance,arg);
		}
		
		public static function removeEventListener(...arg)
		{
			return instance.addEventListener.apply(instance,arg);
		}
		
		//
		//
		//	METHODS
		//
		//
		
		//
		//	Get a reference for an object property pair, or create one if none exists. 
		//
		
		public static function createReference(referenceObject:Object,referenceProperty:String):Reference
		{						
			if(referenceObject is Sprite && (referenceProperty =='pressed' || referenceProperty == 'touched'))
			{
				// check for existing 'interactive'
				var io = getInteractiveFor(referenceObject);
				if(io == null) io = new Interactive(referenceObject as DisplayObject);		
				referenceObject = io;
			}
			
			var newReference : Reference;
			var relationship : Relationship;
			
			// check to see if there's a reference anywhere
			for (var key:Object in dependencies) 
			{
				// iterates through each object key
				if(key.object == referenceObject && key.property == referenceProperty)
				{
					//trace("Binder::createReference():: Reference exists, using existing one.");
					newReference = key as Reference;
				} 
			}		
			
			// If we haven't found a driver, check to see if we have a reference as a dependency
			if(newReference == null)
			{							
				loopA : for each(var relationships : Array in dependencies)
				{
					for each(relationship in relationships)
					{
						if(relationship.driven.object == referenceObject && relationship.driven.property == referenceProperty)
						{
							//trace("Binder::createReference():: Refernce exists as driven, using existing one");
							newReference = relationship.driven;
							break loopA;
						}
					}
				}
			}
			
			// if we still don't have a reference to this, then make a new one.
			if(newReference==null)
			{
				if(referenceProperty == 'rotation' || referenceProperty == 'angle' || referenceProperty == 'angle') newReference = new AngularReference(referenceObject,referenceProperty,currentTimeStamp);
				else newReference = new Reference(referenceObject,referenceProperty,currentTimeStamp);
				//dependencies[newReference] = new Array(); // DANGER?!
			}
			
			if(inputs.indexOf(newReference) == -1 && externalProperties.indexOf(referenceProperty) != -1)
			{
				//trace("Binder::bind(), Driver"+newReference+" is an external input...");
				inputs.push(newReference);
			}
			
			return newReference;
				
		}
				
		public static function parse(statement:String,context:DisplayObject):Relationship
		{
									
			var referenceStrings;
			var driverReference ;
			var drivenReference ;			

			statement = statement.split(' ').join(''); // strip whitespace
			
			if(statement.search("->") != -1) 
			{
				// split on 
				referenceStrings = statement.split('->');				
				
				driverReference = parseExpression(referenceStrings[0],context);  // may consist of something like context.x+10  need to parse...
				drivenReference = parseReference(referenceStrings[1],context);
								
				// bind changes				
				return Binder.bindChanges(driverReference,'targetValue',drivenReference,'targetValue');
			}
			else
			{
				referenceStrings = statement.split('=');
				driverReference = parseExpression(referenceStrings[1],context);  // may consist of something like context.x+10  need to parse...
				drivenReference = parseReference(referenceStrings[0],context);
				trace(driverReference,drivenReference);
				return Binder.bind(driverReference,'targetValue',drivenReference,'targetValue');
			} 						
		}
		
		public static function parseExpression(expressionString:String,context) //:Reference OR number :/
		{

			if(context == null) context = stage;

			var result:Array;
			var expressionSet;

			result = expressionString.split("-");
			if(result.length > 1)
			{
				result[1] = result.splice(1).join("-");	

				result[0] = parseExpression(result[0],context);
				result[1] = parseExpression(result[1],context);

				return Binder.createReference(new Set(result[0],result[1]),'DIFFERENCE');
			}

			result = expressionString.split("+");
			if(result.length > 1)
			{
				result[1] = result.splice(1).join("+");
				trace("found sum", result[0]," and ", result[1]);

				result[0] = parseExpression(result[0],context);
				result[1] = parseExpression(result[1],context);

				trace('result:',result);
				return Binder.createReference(new Set(result[0],result[1]),'SUM');
			}

			result = expressionString.split("/");
			if(result.length > 1)
			{
				result[1] = result.splice(1).join("/");

				result[0] = parseExpression(result[0],context);
				result[1] = parseExpression(result[1],context);

				return Binder.createReference(new Set(result[0],result[1]),'DIV');
			}

			result = expressionString.split("*");
			if(result.length > 1)
			{
				result[1] = result.splice(1).join("/");

				result[0] = parseExpression(result[0],context);
				result[1] = parseExpression(result[1],context);

				return Binder.createReference(new Set(result[0],result[1]),'MULT');
			}

			// check to see if reference (has no word characters)...	
			if(expressionString.search(/[a-zA-Z]/) == -1)
			{
				//.. it is numeric	
				return Number(expressionString); // int or number?
			}
			else if(expressionString.search(/\./) != -1)
			{
				//... it is reference to object...
				return Binder.parseReference(expressionString,context);
			}

			// else
			trace("Binder::parseExpression() :ERROR can't parse:",expressionString);
			return null;//Number(expressionString);	
					
		}
		
		public static function parseReference(referenceString,context):Reference
		{
			if(context == null)
			{
				trace("Binder::getReferenceFromString(referenceString) ERROR: Binder needs reference to a container for"+referenceString+" : (");
				return null;
			}
		
			// this is where we should go all recursive...			
			var objectString	= referenceString.split(".")[0];
			var propertyString  = referenceString.split(".")[1];			
			
			switch(objectString)
			{
				case "Cursor":
					return createReference(Cursor,propertyString); // "Cursor" does ot resolve to Cursor via getDefinitionByName(), it needs to be "net.manipulus.Cursor" :/
					break;
					
				case "Metronome":
					return createReference(Metronome,propertyString);
					break;
									
				case "this":
					return createReference(context,propertyString);
					break;
					
			}
						
			if(context[objectString]==null)
			{
				trace("Binder::getReferenceFromString(referenceString) ERROR "+objectString+" does not exist on stage.");	
				return null;
			}
			else if(context[objectString] is Reference)
			{
				return context[objectString];
			}
			else return createReference(context[objectString],propertyString);
			

		}
		
		// Option to map something as an external property?... this basically sets priority
		//	p1 : external, read only property
		//	p2 : normal relationship
		//	p3 : constraint, ran after others have updated (should just be a dependent of a particular reference...)				
		
		public static function map(...args):Relationship
		{
			if(args[2] is String)
			{
				return bindChanges(args[0],args[1],args[0],args[2],args[3],args[4])
			}			
			
			return bindChanges(args[0],args[1],args[2],args[3],args[4],args[5]);

		}
		
		public static function bindChanges(driverObject:Object,driverProperty:String,drivenObject:Object,drivenProperty:String,mappingFunction:Object=null,delay:uint=0):*
		{
							
			//
			//	parse inputs
			//
			
			// are we dealing with an implicit set?
			if(driverObject is Array && !(driverObject is Set))
			{
				// what if we want to drive an array?... hm...		
				return bindChanges(new Set(driverObject),driverProperty,drivenObject,drivenProperty,mappingFunction,delay);
			}
			
			if(drivenObject is Array && !(driverObject is Set))
			{
				// what if we want to drive an array?... hm...				
				return bindChanges(driverProperty,driverProperty,new Set(drivenObject),drivenProperty,mappingFunction,delay);
			}
			
			// are we using a special property?				
			var interactive:Interactive;
			if((driverProperty == 'touched' || driverProperty == 'pressed') && !(driverObject is Interactive))
			{
				// should check for existing Interactive!!!
				interactive = getInteractiveFor(driverObject);
				if(interactive==null)
				{					
					interactive = new Interactive(driverObject as DisplayObject);
					_instance.interactives.push(interactive);
				}
				return bindChanges(interactive,driverProperty,drivenObject,drivenProperty,mappingFunction,delay);
			}
			if((drivenProperty == 'touched' || drivenProperty == 'pressed') && !(driverObject is Interactive))
			{
				interactive = getInteractiveFor(drivenObject);
				if(interactive==null)
				{

					interactive = new Interactive(drivenObject as DisplayObject);					
					_instance.interactives.push(interactive);
				}
				return bindChanges(driverObject,driverProperty,interactive,drivenProperty,mappingFunction,delay);		
			}
						
			// Probably be better to pass an array for the properties.
			if(driverProperty == 'position' && drivenProperty == 'position' )
			{
				//trace("Binder::bindChanges():: POsiTIon");
				var positionSet = new Set(bindChanges(driverObject,'x',drivenObject,'x',mappingFunction,delay), bindChanges(driverObject,'y',drivenObject,'y',mappingFunction,delay));
				return positionSet;
			}			
			
			//
			//	check for existing references
			//
			
			// check for existing drivers and drivens...
			var driver 				: Reference = null;
			var driven 				: Reference = null;
			var reference 			: Reference;
			var relationship 			: Relationship;
			var dependentRelationship 	: Relationship

			// check for illegal assignments
			if(externalProperties.indexOf(drivenProperty) != -1)
			{
				//trace("Binder::map() WARNING: ",drivenProperty,' can not be driven.');
				return null;
			}			
			
			//
			// Check to see if driver value is already driving things...
			//
			
			// similar to createReference... but not identical... combining these would be ideal.			
			for (var key:Object in dependencies) 
			{
				// iterates through each object key
				if(key.object == driverObject && key.property == driverProperty)
				{
					driver = key as Reference;
					//trace('Using existing driver for '+driver)

					//
					//	check to see if the driven value is already dependent on this driver
					//

					for each(dependentRelationship in dependencies[key])
					{
						if(dependentRelationship.driven.object == drivenObject && dependentRelationship.driven.property == drivenProperty)
						{
							trace('WARNING, relationship between the two properties exists! Ignoring.')
							// check for different relationship or the like...
							return null;
						}
					}

					// while a reference to the driven prop may not exist as a dependency, it may exist elsewhere
					// so need to check after this

				} 
			}		
			
			// If we haven't found a driver, check to see if we have a reference to the potential driver anywhere...
			if(driver == null)
			{							
				loopA : for each(var relationships : Array in dependencies)
				{
					for each(relationship in relationships)
					{
						if(relationship.driven.object == driverObject && relationship.driven.property == driverProperty)
						{
							driver = relationship.driven;
							dependencies[driver] = new Array();
							//trace("Binder::bindChanges(), creating dependecy Array for existing reference, ", driver);
							break loopA;
						}
					}
				}
			}
			
			// if we still don't have a reference to this, then make a new one.
			if(driver==null)
			{
				if(driverProperty == 'rotation' || driverProperty == 'ANGLE' || driverProperty == 'angle') driver = new AngularReference(driverObject,driverProperty,currentTimeStamp);
				else driver = new Reference(driverObject,driverProperty,currentTimeStamp);
				dependencies[driver] = new Array();
				//trace("Binder::bindChanges(), creating new driver reference :" +driver);
			}

			//
			//	Check to see if we have a reference anywhere to the drivenObject.drivenProperty
			//	(might be nice to do a references[obj] or something?, at least faster that way)	
			//	(swap out vector for Array?)
			//	

			var dependenciesForDriver : Array;
			
			// check to see if our dependent is a driver itself
			for (var referenceKey:Object in dependencies)
			{
				if(referenceKey.object == drivenObject && referenceKey.property == drivenProperty)
				{
					//trace("Binder::map(), reference to driven prop already exists as driver, using...");
					driven = referenceKey as Reference;
				}
			}
			
			if(driven == null)
			{
				for each(dependenciesForDriver in dependencies)
				{
					for each(dependentRelationship in dependenciesForDriver)
					{
						//trace('			.'+dependentRelationship.driven.object.name , drivenObject.name)
						if(dependentRelationship.driven.object == drivenObject && dependentRelationship.driven.property == drivenProperty)
						{
							//trace("Binder::map(), WARNING; driven property already driven! One driver only! others will be ignored!");
	//						return;
							//trace("Binder::map(), WARNING; driven property already driven! Only one driver will effect a driven. External inputs are given priority");
							driven = dependentRelationship.driven;
						}
					}
				}
			}
					
			if(driven == null)
			{
				if(drivenProperty == 'rotation' || drivenProperty == 'ANGLE' || drivenProperty == 'angle') driven = new AngularReference(drivenObject,drivenProperty,currentTimeStamp);
				else driven = new Reference(drivenObject,drivenProperty,currentTimeStamp);
				//trace("Binder::map(), creating new driven reference, "+ driven);
			}			

			relationship = new Relationship(driver,driven,mappingFunction,delay);

			dependencies[driver].push(relationship); // info about dependency (relationship latency)? not yet... NOW there is!
		
			
			if(inputs.indexOf(driver) == -1 && (externalProperties.indexOf(driverProperty) != -1 || driverObject == Cursor || driverObject == Metronome || driverObject == Clock))
			{
				//trace(inputs.indexOf(driver));
				//trace("Binder::bind(), adding "+driver+" to inputs...\n");
				inputs.push(driver);
			} 

			//
			// relationships should be a flat list of all relationships probably...
			//
//			if(relationships[driver] == undefined) relationships[driver] = new Array(relationship);
//			else relationships[driver].push(relationship);
			
			instance.dispatchEvent(new RelationshipEvent(RelationshipEvent.MAPPING_CREATED,relationship));
			
			return relationship;
		}

		public static function bind(driverObject:Object,driverProperty:String,drivenObject:Object,drivenProperty:String,mappingFunction:Object=null,delay:uint=0):Relationship
		{
			var m : Relationship = bindChanges(driverObject,driverProperty,drivenObject,drivenProperty,mappingFunction,delay);
				m.absolute = true;
				
			return m;
		}
		
		public static function bindReferences(driver:Reference, driven:Reference, mapping:Function=null, delay:uint=0 ):Relationship
		{
			//
			return null;
		}

		//
		//
		//
		
		public static function unmap(driverObject:Object,driverProperty:String,drivenObject:Object,drivenProperty:String):void
		{
			
			// are we using a special property?
			var interactive:Interactive;
							
			if((driverProperty == 'touched' || driverProperty == 'pressed') && !(driverObject is Interactive))
			{
				interactive = getInteractiveFor(driverObject);
				return unmap(interactive,driverProperty,drivenObject,drivenProperty);
			}
			if((drivenProperty == 'touched' || drivenProperty == 'pressed') && !(driverObject is Interactive))
			{
				interactive = getInteractiveFor(drivenObject);
				return unmap(driverObject,driverProperty,interactive,drivenProperty);		
			}


			// unmap
			
			for(var keyReference:Object in dependencies)
			{
				if(keyReference.object == driverObject && keyReference.property == driverProperty)
				{
					for each(var dependentRelationship in dependencies[keyReference])
					{
						if(dependentRelationship.driven.isTo(drivenObject,drivenProperty))
						{
							var indexOfReference = dependencies[keyReference].indexOf(dependentRelationship);
							dependencies[keyReference].splice(indexOfReference,1);
							
							if(dependencies[keyReference].length == 0)
							{
								delete dependencies[keyReference];
								instance.dispatchEvent(new RelationshipEvent(RelationshipEvent.MAPPING_REMOVED,dependentRelationship));
							}
						}
					}
				}
			}
			
			// need to remove non used instances of an Interactive...			

			/*
			for(keyReference in relationships)
			{
				if(keyReference.isTo(driverObject,driverProperty))
				{
					for each(var relationship:Relationship in relationships[keyReference])
					{
						if(relationship.driven.isTo(drivenObject,drivenProperty))
						{
							var indexOfRelationship = relationships[keyReference].indexOf(relationship);
							relationships[keyReference].splice(indexOfRelationship);
							instance.dispatchEvent(new RelationshipEvent(RelationshipEvent.MAPPING_REMOVED,relationship));
						}
					}
				}
			}
			*/
			
			// remove relationship from relationships
			
		
//			return false;
			// find driver (if there is one)
			// find driven, remove.
			// if no more driven, remove driver
			
		}		
		
		/*
		 	unmapDriver(obj,prop)
		 	unmapDriven(obj,prop)
		 	unmap(obj,prop)
		
		 	undrive()
		 	undriver()
		
			removeDependentsOf(obj,prop)
			removeDriversOf(obj,prop)
					
		*/

		//
		// happens continually? 
		//		Kinda have to... what if we tween something?
		//		unless we can register for events from something like that... i think we can register for tween events...
		// happens when something changes?
		//

		private static function update(e:Event=null)
		{
			if(suspend) return;			
//			trace("Binder::update()");
//			if(e!=null) e.updateAfterEvent;
//			trace("Binder::update()");
			currentTimeStamp = new Date().getTime();

			// proooooobably shouldn't be managing this like so..
			Clock.handleTime(new Event('time'));
			Metronome.handleTime(new Event('time'));


			// update inputs, these are references to things that are read only...
			// keep track of previous and current values...	 	
			
			for each(var inputReference:Reference in inputs)
			{
				inputReference.update(currentTimeStamp);
			}
			
			/*
				//
				// create tree
				//
				
				var tree = new Tree();
				tree.addNodes( dependentRelationships );		// m1, m2
				for each node
				{
					dependentRelationships = dependencies[(node as Relationship).driven]					
					
					// removeRelationships that are already in tree...
					
					node.addNodes( culledDependentRelationships );
					
					for each newNode in dependent node
					{
						dependentRelationships = dependencies[(newNode as Relationship).driven]					
						
						// removeRelationships that are already in tree...
											
						newNode.addNodes( culledDependentRelationships );
						
						//... and so on ...
						
						
					}
				}
			
				for each nodeLevel in tree			// loop from 'top' to 'bottom'
				{
					for each node in nodeLevel		// loop from 'left' to 'right'
					{
						(node as Relationship).resolve();
						(node as Relationship).driven.update();
						// check for changes elsewhere caused by unknown dependencies
					}					
				}
			
				
				// update any other references?
				// this will leave out any thing that change because of a getter setter.
				// getter setters are 'invisible' relationships :/ Any relationships should be known to Binder.  
			
			
			*/


			// 'Propigate changes.' 
			// if we're tracking it, it's because it has things it's driving

			for each(inputReference in inputs)
			{	
//				trace(inputReference);
				propigateChange(inputReference);
			}

			//
			// check for un updated references? stragglers? // NEED TIME AS INPUT?
			//			

			for each( var relationshipArray:Array in dependencies)
			{
				for each(var relationship:Relationship in relationshipArray)
				{
					relationship.driver.update(currentTimeStamp);
					propigateChange(relationship.driver);
				}
			}
			


			// (multiple inputs?, average out, keep track of changes)	
		}

		// so a reference can be updated, and applied
		// don't want to apply more than once... so we.. use a reference to the value to doube check?
		// the references can be used to 'lock out' something from being updated? they can be used to prevent something from being touched?


		// 'updateDependenciesOf'
		// when a referenced value has changed, anything watching it needs to be updated...
		//		update value
		// once it value has been changed, any references to it need to be updated
		//			

		private static function propigateChange(reference:Reference)
		{	 
			var dependentRelationshipsArray = dependencies[reference];
			
//			trace('propigate change of ref:',reference.object.name,reference.property);
//			trace('		has dependents: ' + dependentRelationshipsArray);
			
			for each(var dependentRelationship in dependentRelationshipsArray)
			{				
				if(dependentRelationship.driven.lastTimeStamp < currentTimeStamp)
				{			
					// In this situation, it's ok to touch the value of the dependent reference.
					
					
					// is relationship suspended though?
					if(dependentRelationship.suspend)
					{
						// for one, don't move anything...
						continue;
						
						// for two... any dependent 
						// worried about things tryng to 'catch up' when unsuspended...
						// not going to happen...
						
					}
					
					// SHOULD do something LIKE THIS: (relationships[reference] as Relationship).update();
					// update the value (based on some kind of relationship...)
//					(relationships[reference] as Relationship).update();
					/*
						update()
						{
							// if(suspended) return;
							// mark with timeStamp?
							// switch (type of relationship?)
							// because the following is a delta map...
							drivenReference.drivenObject[drivenReference.drivenProperty] += driverReference.changeInValue; 
							
							// should the driven reference be checked
							// should the driven reference be updated at this point?
							
							// should a mapping just be a function?
							mapping(driverReference,drivenReference);
							
								// can't extend a funciton, so we can't give it custom props...
								// unless I create something _like_ a function...
							
							// what does it need to know?
								what to do with the two references...
								what kind of mapping it is?
								
							// other things can be used to visualize it also
							// .... and it could be modified (it's mapping funciton perhaps) through more mapping...
							
							// what if the references were updated before the objects were?
							// update all the references, then apply the changes? hmm....
							// this would allow for 'forces' to be 
							
							mapping.update(driverReference,drivenReference)
								
							// alternate
								apply
								update
								refresh
								move
								set
								configure
								pushValue
								bringIntoAlignment
								allign
								correct
								reset
								arrange
								applyChange
								propigateChange								
								RESOLVE	<- !
						}
					*/
					
					// wold it be ok to update based on two different drivers if they had different delays?...
//					trace("		pushing reference value to object: "+dependentRelationship.driven.object.name+" prop: " + dependentRelationship.driven.property +' : '+reference.changeInValue);
					//dependentRelationship.driven.object[dependentRelationship.driven.property] += reference.changeInValue;	//where is the mapping kept? In the driver? No, separate...
					
					// get mapping for driverReference to drivenReference
					// use to apply change... eventually we'll use the mapping function stored in the mapping instance.
					//dependentRelationship.driven.object[dependentRelationship.driven.property] += dependentRelationship.mappingFunction.apply(dependentRelationship.mappingFunction,[ dependentRelationship.driver.changeInValueAtTime(currentTimeStamp - dependentRelationship.delay)] );

					// migrating to doing it this way...
					dependentRelationship.resolve(currentTimeStamp);
					
					// update the dependent reference			
					dependentRelationship.driven.update(currentTimeStamp);	// Should this be done inside the mapping.resolve() ?...
					
					// propigate the change...				
					propigateChange(dependentRelationship.driven);			
				}
			}

		}
		
		//
		//	EVENT LISTENERS
		//
				
		public function handleExternalEvent(e:MouseEvent)
		{
			update();
			e.updateAfterEvent();
			// check inputs
			/*for each(var reference:Reference in dependencies)
			{
				if(reference.object == stage)
				{
					update();
					e.updateAfterEvent();
					return;
				}
			}*/
		}
		
		//
		//
		//
		
		// Looks for an existing interactive following an object
		public static function getInteractiveFor(obj:Object):Interactive
		{
			for each (var item:Interactive in _instance.interactives)
			{
				if(item.isFollowing(obj as DisplayObject)) return item;
			}
			return null;
		}
		

		//
		//
		//
		
		public function getReferencesTo(object:Object):Array
		{
			var references = [];
			for each(var reference:Reference in dependencies)
			{
				if(reference.object == object) references.push(reference)		
			}
			return references;
		}

	


		//
		//
		// SINGLETON HELPER FUNCTINONS
		//
		//
		
		// find any relationships that involve the entity
		public static function getRelationshipsInvolving(object:Object):Array
		{	
			
			var relatedRelationships = [];		
			
			for each (var dependentRelationships:Array in dependencies)
			{
				for each(var dependentRelationship : Relationship in dependentRelationships)
				{
					if(dependentRelationship.isTo(object) || dependentRelationship.isFrom(object))
					{
						if(relatedRelationships.indexOf(dependentRelationship) == -1) relatedRelationships.push(dependentRelationship);
					} 
				}
			}
		
			return relatedRelationships;
			
		}
		
		
		// sequential tie?
		public static function tie(items:Array,property:String,mappingFunction:Object=null,delay:uint=0):Array
		{
			if(items.length < 2) return [];
			
			var newRelationships:Array = [];
			
			for(var i = 0; i < items.length; i++)
			{
				var ni = (i+1)%items.length;
//				var pi = ((i-1)+items.length)%items.length;
				newRelationships.push(bindChanges(items[i],property,items[ni],property,mappingFunction,delay));				
//				newRelationships.push(bindChanges(items[i],property,items[pi],property,mappingFunction,delay));	// doesn't resolve in ideal order. 
			}
			
			return newRelationships;
		}
		
		// Short cuts for dragging... shouldn't be tied to clips.. should be able to drag any property...
		public static function drag(clip:DisplayObject):Array
		{
			if(clip.stage == null)
			{
				trace("Binder::drag() WARNING : Can not drag a clip that is not on the stage");
				return null;
			}
			
			return [bindChanges(clip.stage,'mouseX',clip,"x"),bindChanges(clip.stage,'mouseY',clip,"y")];
			
		}
		
		/**
		* This will break when the clip is in another clip...	
		* Should probably use the clip's parent somehow...
		* 	 
		*
		*/
		public static function makeDraggable(clip:DisplayObject):void
		{
//			bind(clip,'pressed',bindChanges(Cursor,'x',clip,"x"),'active');
//			bind(clip,'pressed',bindChanges(Cursor,'y',clip,"y"),'active');
		}				
		
		public static function dragX(clip:DisplayObject):Relationship
		{
			if(clip.stage == null)
			{
				trace("Binder::dragX() WARNING : Can't not drag a clip that is not on the stage");
				return null;
			}
			
			return bindChanges(clip.stage,'mouseX',clip,"x");
		}
		
		public static function dragY(clip:DisplayObject):Relationship
		{
			if(clip.stage == null)
			{
				trace("Binder::dragY() WARNING : Can't not drag a clip that is not on the stage");
				return null;
			}
						
			return bindChanges(clip.stage,'mouseY',clip,"y");
		}
		
		public static function stopDrag(clip:DisplayObject):Boolean
		{
//			trace("Binder::stopDrag()");
			unmap(clip.stage,'mouseX',clip,"x");
			unmap(clip.stage,'mouseY',clip,"y");
			return true;
		}

	}

}
