import net.manipulus.*;

// init
Binder.init(stage);

// shortcuts for bindChanges
var map = Binder.bindChanges;
var mapChanges = Binder.bindChanges;
var bindChanges = Binder.bindChanges;
var bindDelta = Binder.bindChanges;

// shortcuts for bind
var MAP = Binder.bind;
var mapValues = Binder.bind;
var bindValues = Binder.bind;
var bind = Binder.bind;

var point = Binder.createReference;

// parsing...
var parse = function(expressionString)
{
	return Binder.parse(expressionString,this);
}

var $ = parse; // ! = D

//..

function BIND(ref1,ref2,mapping=null,delay=0):Relationship
{
	return bind(ref1,'targetValue',ref2,'targetValue',mapping,delay);
}

function BIND_CHANGES(ref1,ref2,mapping=null,delay=0):Relationship
{
	return bindChanges(ref1,'targetValue',ref2,'targetValue',mapping,delay);
}


// ...

var VALUE_OF  = Binder.createReference;
//var $ = Binder.createReference; 

function AND(...args):Reference
{
	if(args.length == 4){
		return AND(VALUE_OF(args[0],args[1]),VALUE_OF(args[2],args[3]));
	}
	
	return VALUE_OF(new Set(args[0],args[1]), 'AND');

}

function OR(...args):Reference
{
	if(args.length == 4){
		return OR(VALUE_OF(args[0],args[1]),VALUE_OF(args[2],args[3]));
	}	
	return VALUE_OF(new Set(args[0],args[1]), 'OR');
}

function GREATER_THAN(...args):Reference
{
	if(args.length == 4){
		return GREATER_THAN(VALUE_OF(args[0],args[1]),VALUE_OF(args[2],args[3]));
	}	
	return VALUE_OF(new Set(args[0],args[1]), 'GREATER_THAN');
}

function LESS_THAN(...args):Reference
{
	if(args.length == 4){
		return LESS_THAN(VALUE_OF(args[0],args[1]),VALUE_OF(args[2],args[3]));
	}	
	return VALUE_OF(new Set(args[0],args[1]), 'LESS_THAN');
}

function DIFFERENCE(...args):Reference
{
	if(args.length == 4){
		return DIFFERENCE(VALUE_OF(args[0],args[1]),VALUE_OF(args[2],args[3]));
	}	
	return VALUE_OF(new Set(args[0],args[1]), 'DIFFERENCE');
}

function ANGLE(...args):Reference
{
	if(args.length == 4){
		return ANGLE(VALUE_OF(args[0],args[1]),VALUE_OF(args[2],args[3]));
	}	
	return VALUE_OF(new Set(args[0],args[1]), 'ANGLE');
}
