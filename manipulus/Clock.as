/**


*/

package net.manipulus
{	
	
	import flash.utils.*;
	import flash.events.*;
	
	public class Clock extends Object
	{
		
		private static var _instance:Clock				

		protected var _milliseconds:int;
		protected var _seconds:int;			
		protected var _minutes:int;
		protected var _hours:int;
		protected var _time:int;
		
		protected var _timer:Timer;
		
		public function Clock()
		{
			super();
			_timer = new Timer(1000/60);
		}
		
		public static function init()
		{
			if(_instance!=null)
			{
				trace("Clock::init() : Warning : Clock.init may only be called once");
			}
			_instance = new Clock();								
			/*_instance._timer.addEventListener(TimerEvent.TIMER,Clock.handleTime);	
			_instance._timer.start();
			*/
			handleTime(new Event('bunk')); // auto set the clock*/
		}
		
		
		
		public static function handleTime(event:Event):void
		{
//			if(stopped) return;
			var currentTime: Date = new Date();
			var inst : Clock   = instance;
			inst._milliseconds = currentTime.getMilliseconds();
			inst._seconds      = currentTime.getSeconds();				
			inst._minutes      = currentTime.getMinutes();
			inst._hours        = currentTime.getHours();
			inst._time         = currentTime.getTime();			

		}
		
		public static function stop()
		{
//			instance._timer.stop();			
		}
		
		public static function start()
		{
//			instance._timer.start();
		}	
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
	
		public static function get instance():Clock
		{
			if(_instance == null) init();
			return _instance;
		}
	
		public static function get milliseconds():int
		{
			return instance._milliseconds;
		}
		
		public static function get seconds():int
		{
			return instance._seconds;
		}
		public function get fractionSeconds():Object
		{
			return instance._seconds + instance._milliseconds/1000;
		}
		
		public static function get minutes():int
		{
			return instance._minutes;
		}
		
		public static function get hours():int
		{
			return instance._hours;
		}		

		public static function get time():int
		{
			return instance._time;
		}
		
		public function toString():String
		{
			return "Clock";
		}
	}
}