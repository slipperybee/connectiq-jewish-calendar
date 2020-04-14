module JewishCalendarModule {
	class GeoLocation {
		var name;
		var latitude;
		var longitude;
		var elevation;
	
		function initialize(myname, mylatitude, mylongitude, myelevation)
		{
			name = myname;
			latitude = mylatitude;
			longitude = mylongitude;
			elevation = myelevation.toFloat();
		}
			
		function toString() {
			return "latitude: "+latitude+", longitude: "+longitude +", elevation: "+elevation;
		}
	}
}