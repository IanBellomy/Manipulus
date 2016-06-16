package net.manipulus
{	
	
	import flash.events.*;	
	
	public class Metronome extends Object
	{
	
		private static var _instance	: Metronome;
	
		protected var _thirtysecondNotes:int;
		protected var _sixteenthNotes:int;
		protected var _quarterNotes:int;
		protected var _halfNotes:int;
		protected var _wholeNotes:int;
		protected var _measures:int;
		protected var _totalBeats:int;
		protected var _beatsPerMinute:int         = 120;
		protected var _millisecondsPerBeat:Number = 500;
		protected var _beatsPerMeasure : int      = 4;

				
		protected var _lastTime:Date;
		protected var _startTime:Date;
		
		protected var _stopped	: Boolean = false;
		

		
		public function Metronome()
		{
			super();			
		}
		
		public static function init()
		{
			if(_instance!=null)
			{
				trace("Metronome::init() : Warning, init may only be called once");
			}
			//trace("Metronome::init()");
			_instance = new Metronome();
			start();
		}
		
		public static function handleTime(e:Event = null)
		{
			if(instance._stopped) return;			
						
			var currentTime          = new Date();	// should get a consistant time stamp...			
			var inst:Metronome       = instance;			
			var timeRunning : Number = currentTime.getTime() - inst._startTime.getTime();
			
			inst._totalBeats  = Math.floor(timeRunning / millisecondsPerBeat);
			
			inst._thirtysecondNotes  = Math.floor(timeRunning / (inst._millisecondsPerBeat/4))%2;
			inst._sixteenthNotes  = Math.floor(timeRunning / (inst._millisecondsPerBeat/2))%2;
		    inst._quarterNotes 	  = Math.floor(timeRunning / inst._millisecondsPerBeat)%inst._beatsPerMeasure;
		    inst._halfNotes    	  = Math.floor(inst._quarterNotes/2);
//		    inst._wholeNotes   	  = Math.floor(timeRunning / (inst._millisecondsPerBeat*4));
		    inst._measures   	  = Math.floor(inst._totalBeats/inst._beatsPerMeasure);			
			
		}	
		
		public static function start():void
		{
			_instance._startTime         = new Date();
			_instance._stopped           = false;			
			_instance._thirtysecondNotes = 0;
			_instance._sixteenthNotes    = 0;
		    _instance._quarterNotes   = 0;
		    _instance._halfNotes      = 0;
//		    _instance._wholeNotes   = 0;
		    _instance._measures       = 0;
			_instance._totalBeats        = 0

		}
		
		public static function stop():void
		{
			instance._stopped = true;
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
	
		public static function get instance():Metronome
		{
			if(_instance==null) init();			
			return _instance;
		}	
	
		public static function get thirtysecondNotes():int
		{
			return instance._thirtysecondNotes;
		}
	
		public static function get sixteenthNotes():int
		{
			return instance._sixteenthNotes;
		}		
	
		public static function get quarterNotes():int
		{
			return instance._quarterNotes;
		}	
		
		public static function get halfNotes():int
		{
			return instance._halfNotes;
		}

		public static function get wholeNotes():int
		{
			return instance._wholeNotes;
		}
		
		public static function get measures():int
		{
			return instance._measures;
		}

		public static function get totalBeats():int
		{
			return instance._totalBeats;
		}

		public static function get beatsPerMinute():int
		{
			return instance._beatsPerMinute;
		}
		
		public static function get millisecondsPerBeat():Number
		{
			return instance._millisecondsPerBeat;
		}
	
		public static function set beatsPerMinute(value:int):void
		{
			instance._beatsPerMinute = value;
			instance._millisecondsPerBeat	= 1000/(value/60);
		}
	
		public static function set beatsPerMeasure(value:int):void
		{
			instance._beatsPerMeasure = value;
		}
	
	}
}
