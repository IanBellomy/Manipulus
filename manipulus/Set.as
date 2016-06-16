/*

	index	// moves the whole selection

	startIndex?
	endIndex?
		
	falloff/weight ? // weighted selection?
		// distinguish between

	
	How to see if something is selected...
		
		Binder.map(clip,'selected',clip,'alpha'); 
		
		Binder.map(selection,'0_selected',clip,'alpha');
		

		Binder.map(selection,'selection')
		
		for all items
		{
		map(item,'alpha',item,'selected')
		}	
				
		Binder.bindChangesMany(selection,'selected',selection,'alpha');
	
		//
		
		selection.x
		selection.x_all
		selection.each_x
	
*/

package net.manipulus
{
    import flash.utils.flash_proxy;
    import flash.utils.Proxy;
	import flash.geom.*;
	import flash.display.*;
	
    use namespace flash_proxy;

    dynamic public class Set extends Proxy
    {
        protected var _array:Array;
		protected var _index:int = 0;			 // startIndex
		protected var _selectionRange:int	= 1; // ?!

		//public var selectionStart	:int=0;
		//public var selectionStop	:int=1;

        public function Set(...parameters)
        {
			//trace(parameters);
			if(parameters.length == 1 && parameters[0] is Array) _array = parameters[0];				
            else _array = parameters;
        }

		//
		//	getter setters
		//
		
		public function get index():int
		{
			return _index;
		}
		
		public function set index(value:int):void
		{
			/*trace("Set::set selection()");
			trace(value,_array.length+1);
			trace(value%(_array.length+1));*/
			_index = (value+_array.length*1000)%(_array.length);	// repeat vs. ping-pong?
		}


		public function valueOf():*
		{
			return _array[_index];
		}

		
		//
		//	Relationships values
		//
		
		public function get midpoint():Point
		{
			var obj1 = this[0];
			var obj2 = this[this.length-1];

			var mpx	= (obj2['x'] - obj1['x'])/2 + obj1['x'];;
			var mpy	= (obj2['y'] - obj1['y'])/2 + obj1['y'];;
			return new Point(mpx,mpy);
		}		
		
		public function get midpointX():Number
		{
			var obj1 = this[0];
			var obj2 = this[this.length-1];
			return (obj2['x'] - obj1['x'])/2 + obj1['x'];
		}
		
		public function get midpointY():Number
		{
			var obj1 = this[0];
			var obj2 = this[this.length-1];

			return (obj2['y'] - obj1['y'])/2 + obj1['y'];
		}
		
		public function get distance():Number
		{
			var obj1 = this[0];
			var obj2 = this[this.length-1];
			return Point.distance(new Point(obj1['x'],obj1['y']),new Point(obj2['x'],obj2['y']));	
		}
		
		public function set distance(n:Number):void
		{
			var obj1 = this[0];
			var obj2 = this[this.length-1];
			var point : Point = new Point(obj2.x-obj1.x,obj2.y -obj1.y);
			point.normalize(n);
			
			obj2.x = point.x + obj1.x; 
			obj2.y = point.y + obj1.y; 			
			
		}	
		
		public function get AND():Boolean
		{
			return Boolean(this[0] & this[1]);
		}
		
		public function get OR():Boolean
		{
			return Boolean(this[0] | this[1]);
		}
		
		public function get GREATER_THAN():Boolean
		{
			return Boolean(this[0]+0 > this[1]+0);
		}
		
		public function get LESS_THAN():Boolean
		{
			return Boolean(this[0] < this[1]);
		}
		
		public function get EQUAL():Boolean
		{
			return Boolean(this[0] == this[1]);			
		}
		
		public function get NOT_EQUAL():Boolean
		{
			return Boolean(this[0] != this[1]);			
		}
		
		public function get DIFFERENCE():Number
		{
			return this[0] - this[1];
		}
		
		public function get MULT():Number
		{
			return this[0] * this[1];
		}

		public function get DIV():Number
		{
			return this[0] / this[1];
		}

		public function get SUM():Number
		{
			return this[0] + this[1];
		}
		
		/**
		*
		* Should check to see if the objects have x and y properties
		*
		*/
		public function get angle():Number
		{
			var obj1 = this[0];
			var obj2 = this[this.length-1];
			var y_	= obj2.y - obj1.y;
			var x_	= obj2.x - obj1.x;
			var angle_:Number = Math.atan2(y_,x_);	
			return angle_ * 360/(Math.PI*2);
		}			

		public function get ANGLE():Number
		{
			var obj1 = this[0];
			var obj2 = this[this.length-1];
			var y_	= obj2.y - obj1.y;
			var x_	= obj2.x - obj1.x;
			var angle_:Number = Math.atan2(y_,x_);	
			return angle_ * 360/(Math.PI*2);
		}			

		
		public function get touching():Boolean
		{
			var obj1 = this[0];
			var obj2 = this[this.length-1];
			if(obj1 is Sprite && obj2 is Sprite)
			{
				return obj1.hitTestObject(obj2);
			}
			return false;
			
		}

		//
		//	proxy overrides
		//

        override flash_proxy function callProperty( name:*, ...rest):* 
        {        	
			
			if(_array[name] != undefined){
				return _array[name].apply(_array, rest);	
			}
			else
			{
				var returnValues = []
				for(var i = 0; i < _array.length; i++){
					returnValues.push(_array[i][name].apply(_array[i], rest));
				}
				return returnValues;
			}
            
        }

        override flash_proxy function getProperty(name:*):* 
        {
        	
			var nameString : String = name.toString();
			if(nameString.substr(0,9) == 'selected_')
			{
				var n	= Number(nameString.split('_')[1]);
				return n == _index;
			}
			else if(nameString.substr(0,9) == 'distance_' || nameString.substr(0,11) == 'difference_')
			{				
				var propertyName = nameString.split('_')[1];
				var obj1         = this[0];
				var obj2         = this[this.length-1];	
				return obj2[propertyName] - obj1[propertyName];
			}
			else if(_array[name] == undefined) 
			{
				if( _array[_index][name] is Number){

					var vals = [];
					for(var i:int = 0; i < _array.length; i++){
						vals.push(_array[i][name]);
					}
					return vals;
				}

				// all else fails, return the value of the selected item				
				return _array[_index][name];
			}
			else
			{				
				return _array[name];
			}	         
        }

        override flash_proxy function setProperty(name:*, value:*):void 
        {			
        	//trace('setProperty ', name);			
			var nameString : String = name.toString();
			var i = 0;
			if(nameString.substr(0,5) == 'scale' && nameString.length == 5){
				//because 'value' may be mutable, we can't pass it back in recursively, because it may end up being different for scaleX and scaleY
				var immutableValue;
				for(i = 0; i < _array.length; i++){
					immutableValue 	= value + 0;
					_array[i]['scaleX'] = immutableValue;
					_array[i]['scaleY'] = immutableValue;
				}
			}
			else if(nameString.substr(0,9) == 'selected_')
			{
				// what if the value is false, and now there is no index value...
//				var n	= Number(nameString.split('_')[1]);
//				_index = n;
				return;
			}
			else if(nameString.substr(0,9) == 'distance_')
			{			
				// assuming adjustment from [0]
				// range_x_scaleMode = 'left','center','right'?...
				
				var propertyName = nameString.split('_')[1];
				var obj1          = this[0];
				var obj2         = this[this.length-1];				
				var delta = obj1[propertyName] - value;
				obj1[propertyName] -= delta;
				obj2[propertyName] -= delta;
				return;
			}			
			else if(_array[name] == undefined)  // not trying to set a property on THIS thing...
			{
				// ALL, not index

				// ! DANGER DANGER  ! : SHOULDN'T BE ASSUMING THAT THERE IS ACTUALLY ITEMS IN HERE !
				if(value is Array){					
					var inputLength = value.length;
					for(i = 0; i < _array.length; i++){						
						_array[i][name] = value[i%inputLength]; // ! DANGER DANGER ! SHOULDN'T BE ASSUMING value ARRAY IS SAME LENGTH AS _array  !
					}
				}
				else{ // otherwise, just assign the single number to each
					for(i = 0; i < _array.length; i++){					
						_array[i][name] = value;	// handle error? if possible?	
					}
				}
				
			}
			else
			{				
				_array[name] = value;
			}

        }
		
		public function toString():String
		{
			var str = "[Set [";
			for each (var item:Object in _array)
			{
				str+=item.toString() +' ';
			}
			str+=']]';
			return str;
		}

    }
}
