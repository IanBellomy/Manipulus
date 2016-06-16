//
//	Binder
//

	STATIC METHODS


	Binder.bindChanges(
				driverObject	:Object,
				driverProperty	:String,
				drivenObject	:Object,
				drivenProperty	:String,
				mapping			:*,
				delay			:int)	: Relationship
	
		
			Maps relative changes in driverProperty to changes in drivenProperty.
				ex.				
					Binder.map(stage,'mouseX',clip,'x'); // the clip's x position will move in relation to the cursor's x position.
				
			if 'mapping' is a number, then it will act as a multiplier. 
				ex.				
					Binder.map(stage,'mouseX',clip,'x',2); // the clip will move twice as much as cursor
				
			'mapping' may also be a string in the form of: 
				ex.
					
					"*2"
					"/2"
					"+2"
					"-2"
					
				In these cases the statement is performed on the change in the driver property before being used to update the drivenProperty

			'delay' is the number of milliseconds until a change in the driver property is applied to changes in the driven property.
				
		

	Binder.bind(
				driverObject	:Object,
				driverProperty	:String,
				drivenObject	:Object,
				drivenProperty	:String,
				mapping			:*,
				delay			:int)	: Relationship
	
	
				Makes the drivenProperty match, exactly, the driverProperty.
	
	Binder.drag(clip)
	
				a shortcut for the following
				
					Binder.bindChanges(stage,'mouseX',clip,'x');
					Binder.bindChanges(stage,'mouseY',clip,'y');	
				
	
	Binder.makeDraggable(clip)
	
	 			a shortcut for the following
	
					Binder.bindChanges(stage,'mouseX',clip,'x').isIf(clip,'pressed');
					Binder.bindChanges(stage,'mouseY',clip,'y').isIf(clip,'pressed');


	Binder.tie([objects])
	
		...

//
//	Clock
//

	STATIC PROPERTIES
	
	Clock.time			: int	 (read-only) 	// number of milliseconds past 1/1/1970
	Clock.milliseconds  : int    (read-only)	// number of milliseconds passed in the second.
	Clock.seconds       : int    (read-only)	// number of seconds passed in the minute.
	Clock.minutes       : int    (read-only)	// number of minutes passed in the hours.
	Clock.hours			: int    (read-only)	// number of hours passed in the day.
	

//
//	Metronome
//

	STATIC PROPERTIES
	
	Metronome.beatsPerMinute		: int
	Metronome.beatsPerMeasure		: int
	Metronome.millisecondsPerBeat 	: Number (read-only)

	Metronome.totalBeats			: int	(read-only)		// how many beats since started.
	Metronome.thirtysecondNotes		: int	(read-only)
	Metronome.sixteenthNotes		: int   (read-only)
	Metronome.quarterNotes			: int   (read-only)
	Metronome.halfNotes           	: int	(read-only)
	Metronome.measures				: int	(read-only)		// how many measures since started.

	STATIC METHODS
	
	start()
	
		Starts metronome. Resets totalBeats to 0
		
	stop()
	
		Stops metronome. 
	
	
//
//	Set
//

	Properties
	
		index		: int					// The selected item. 	
		[property]	: *						// the [property] of the item at index. Can be read or written to as the property allows. 
	
		selected_#	: Boolean 	(read-only)	// where # is an int. true if # is equal to index, otherwise false
	
		distance	: Number	(read-only)
		midpoint	: Point     (read-only)
		midpointX	: Number    (read-only)
		midpointY	: Number    (read-only)
		
		distance_prop	: 			(read-only)	// where 'prop' is a property name. The difference between the values of the property between the first and last items.


//
//	Reference
//

	A read-only reference to a property. Like a 'pointer'.
	
	
//
//	Relationship
//

	Contains information about a relationship between two References. 