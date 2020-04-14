using Toybox.Math as Maths;
using Toybox.System as System;

module JewishCalendarModule {	
	module ExtendedMaths
	{
		const PI_2 = Maths.PI / 2.0;
	
		function toDegrees (angrad) {
			return Maths.toDegrees(angrad);
		}
		
		function toRadians (degrees) {
			return Maths.toRadians(degrees);
		}
		
		function sinDeg(deg) {
			return Maths.sin(Maths.toRadians(deg));
		}
		
		function tanDeg(deg) {
			return Maths.tan(Maths.toRadians(deg));
		}
		
		function cosDeg(deg) {
			return Maths.cos(Maths.toRadians(deg));
		}
		
		function asinDeg(x) {
			return Maths.toDegrees(Maths.asin(x));
		}
		
		function acosDeg(x) {
			return Maths.toDegrees(Maths.acos(x));
		}
		
		function floor(x) {
			var stringX = x.toString();
			var decimalPoint = stringX.find(".");
			if (decimalPoint == null) {
				return x;
			}
			
    		var integerPart = stringX.substring(0, decimalPoint);
     		//System.println(integerPart);
     		var integerNumber = integerPart.toNumber();
     		
     		return (integerNumber == x) ? x : (integerNumber < x) ? integerNumber : ((integerNumber - 1) < x) ? integerNumber - 1 : 0;
		}
		
		function atan2(y, x)
  		{
  			var absx, absy, val;
	  
	        if (x == 0 && y == 0) {
	        	return 0;
	        }
	        
	        absy = y < 0 ? -y : y;
	        absx = x < 0 ? -x : x;
	        if (absy - absx == absy) {
	                  // x negligible compared to y 
	                  return y < 0 ? -PI_2 : PI_2;
	        }
	        if (absx - absy == absx) {
	                  // y negligible compared to x */
	                  val = 0.0;
	          } else {
	              val = Maths.atan(y/x);
	          }
	          if (x > 0) {
	                  // first or fourth quadrant; already correct */
	                  return val;
	          }
	          if (y < 0) {
	                 // third quadrant */
	                 return val - Maths.PI;
	          }
	          return val + Maths.PI;
	 	 }
	  
		function rotateCoordinate (point, originPoint, angle) {
		 	var angleRadians = toRadians(angle);
	
			var transformX = point[0] - originPoint[0];
			var transformY = point[1] - originPoint [1];
		 	
		 	return [transformX * Maths.cos(angleRadians) - transformY * Maths.sin(angleRadians) + originPoint[0], 
		 			transformY * Maths.cos(angleRadians) + transformX * Maths.sin(angleRadians) + originPoint[1]];
	 	
		}
		
		 // range reduce hours to 0..23
	    function fixhour(a) {
	        a = a - 24.0d * floor(a / 24.0d);
	        a = a < 0 ? (a + 24) : a;
	        return a;
	    }
	    
	    function fixangle(a) {
	    	a = a - (360 * (floor(a / 360.0d)));
	        a = a < 0 ? (a + 360) : a;
	        return a;
  		}

	    // degree sin
	    function dsin(d) {
	        return (Maths.sin(toRadians(d)));
	    }

	    // degree cos
	    function dcos(d) {
	        return (Maths.cos(toRadians(d)));
	    }

	    // degree tan
	    function dtan(d) {
	        return (Maths.tan(toRadians(d)));
	    }

	    // degree arcsin
	    function darcsin(x) {
	        var val = Maths.asin(x);
	        return toDegrees(val);
	    }

	    // degree arccos
	    function darccos(x) {
	        var val = Maths.acos(x);
	        return toDegrees(val);
	    }

	    // degree arctan
	    function darctan(x) {
	        var val = Maths.atan(x);
	        return toDegrees(val);
	    }

	    // degree arctan2
	    function darctan2(y, x) {
	        var val = atan2(y, x);
	        return toDegrees(val);
	    }

	    // degree arccot
	    function darccot(x) {
	        var val = atan2(1.0d, x);
	        return toDegrees(val);
	    }
	  
	}
}