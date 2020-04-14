using Toybox.Time as Time;

module JewishCalendarModule {
	module ZmanimCalendars
	{
		const GEOMETRIC_ZENITH = 90;
	
		class AstronomicalCalendar
		{
			const CIVIL_ZENITH = 96;
			const NAUTICAL_ZENITH = 102;
			const ASTRONOMICAL_ZENITH = 108;
			const ZENITH_11_POINT_5 = GEOMETRIC_ZENITH + 11.5;
			
			hidden var calendar;
			hidden var geoLocation;
			hidden var candleLightingOffset = 18;
			
			hidden function getAstronomicalCalculator()
			{
				return new ZmanimCalculators.SunTimesCalculator();
			}
			
			function initialize(ingeoLocation) 
			{
				calendar = Time.now();
				geoLocation = ingeoLocation;
			}
				
			function getSunrise()
			{
				var sunrise = getUTCSunrise(GEOMETRIC_ZENITH);
				if (null == sunrise) {
					return null;
				} else {
					return getDateFromTime(sunrise);
				}
			}
			
			function getSeaLevelSunrise()
			{
				var sunrise = getUTCSeaLevelSunrise(GEOMETRIC_ZENITH);
				if (null == sunrise) {
					return null;
				} else {
					return getDateFromTime(sunrise);
				}
			}
			
			function getSunriseOffsetByDegrees(offsetZenith)
			{
				var dawn = getUTCSunrise(offsetZenith);
				if (null == dawn) {
					return null;
				} else {
					return getDateFromTime(dawn);
				}
			}
			
			function getSunset() {
				var sunset = getUTCSunset(GEOMETRIC_ZENITH);
				if (null == sunset) {
					return null;
				} else {
					//return getAdjustedSunsetDate(getDateFromTime(sunset), getSunrise());
					return getDateFromTime(sunset);
				}
			}
			
			function getSeaLevelSunset() {
				var sunset = getUTCSeaLevelSunset(GEOMETRIC_ZENITH);
				if (null == sunset) {
					return null;
				} else {
					//return getAdjustedSunsetDate(getDateFromTime(sunset), getSunrise());
					return getDateFromTime(sunset);
				}
			}
			
			function getSunsetOffsetByDegrees(offsetZenith) {
				var sunset = getUTCSunset(offsetZenith);
				if (null == sunset) {
					return null;
				} else {
					//return getAdjustedSunsetDate(getDateFromTime(sunset), getSunrise());
					return getDateFromTime(sunset);
				}
			}
			
			hidden function getDateFromTime(time) {
				if (null == time) {
					return null;
				}
				var calculatedTime = time;
	
				var clockTime = System.getClockTime();
				var timeInfo = Time.Gregorian.info(calendar, Toybox.Time.FORMAT_SHORT);
							 
				var hours = calculatedTime.toNumber();
				calculatedTime -= hours;
				calculatedTime *= 60;
				var minutes = calculatedTime.toNumber(); // retain only the minutes
				calculatedTime -= minutes;
				calculatedTime *= 60;
				var seconds = calculatedTime.toNumber(); // retain only the seconds
				calculatedTime -= seconds; // remaining milliseconds
							
				var cal = Time.Gregorian.moment({:year=>timeInfo.year, :month=>timeInfo.month, :day=>timeInfo.day,
													:hour=>hours, :minute=>minutes, :second=>seconds});
	
				var gmtOffset = (clockTime.timeZoneOffset - clockTime.dst) / 3600;
				if (time + gmtOffset > 24) {
					var duration = Time.Gregorian.duration({:days=>-1});
					cal = cal.add(duration);
				} else if (time + gmtOffset < 0) {
					var duration = Time.Gregorian.duration({:days=>1});
					cal = cal.add(duration);
				}
	
				return cal;
			}
			
			function getUTCSunrise(zenith) {
				return getAstronomicalCalculator().getUTCSunrise(calendar, geoLocation, zenith, true);
			}
			
			function getUTCSeaLevelSunrise(zenith) {
				return getAstronomicalCalculator().getUTCSunrise(calendar, geoLocation, zenith, false);
			}
			
			function getUTCSunset(zenith) {
				return getAstronomicalCalculator().getUTCSunset(calendar, geoLocation, zenith, true);
			}
			
			function getUTCSeaLevelSunset(zenith) {
				return getAstronomicalCalculator().getUTCSunset(calendar, geoLocation, zenith, false);
			}
			
			function getTimeOffset(time, offset) {
				if (time == null) {
					return null;
				}
				return time.add(Time.Gregorian.duration({:seconds=>offset}));
			}
			
			function getTemporalHour() {
				return getSpecificTemporalHour(getSeaLevelSunrise(), getSeaLevelSunset());
			}
			
			function getSpecificTemporalHour(startOfday, endOfDay) {
				if (startOfday == null || endOfDay == null) {
					return 0;
				}
				return (endOfDay.value() - startOfday.value()) / 12;
			}
			
			function getSunTransit() {
				return getSpecificSunTransit(getSeaLevelSunrise(), getSeaLevelSunset());
			}
			
			function getSpecificSunTransit(startOfDay, endOfDay) {
				var temporalHour = getSpecificTemporalHour(startOfDay, endOfDay);
				return getTimeOffset(startOfDay, temporalHour * 6);
			}
		}
		
		class ZmanimCalendar extends AstronomicalCalendar
		{
			hidden static const ZENITH_8_POINT_5 = GEOMETRIC_ZENITH + 8.5;
			hidden static const ZENITH_16_POINT_1 = GEOMETRIC_ZENITH + 16.1;
		
			function initialize(ingeoLocation, setCalendar) 
			{
				AstronomicalCalendar.initialize(ingeoLocation);
				calendar = setCalendar;
				geoLocation = ingeoLocation;
			}
		
			function getTzait()
			{
				return getSunsetOffsetByDegrees(ZENITH_8_POINT_5); 
			}
			
			function getAlotHashachar()
			{
				return getSunriseOffsetByDegrees(ZENITH_16_POINT_1); 
			}
			
			function getAlot72() {
				return getTimeOffset(getSeaLevelSunrise(), -72 * Time.Gregorian.SECONDS_PER_MINUTE);
			}
			
			function getChatzot() {
				return getSunTransit();
			}
			
			function getSofZmanShma(startOfDay, endOfDay) {
				var shaahZmanit = getSpecificTemporalHour(startOfDay, endOfDay);
				return getTimeOffset(startOfDay, shaahZmanit * 3);
			}
			
			function getSofZmanShmaGRA() {
				return getSofZmanShma(getSeaLevelSunrise(), getSeaLevelSunset());
			}
			
			function getSofZmanShmaMGA() {
				return getSofZmanShma(getAlot72(), getTzait72());
			}
			
			function getTzait72() {
				return getTimeOffset(getSeaLevelSunset(), 72 * Time.Gregorian.SECONDS_PER_MINUTE);
			}
			
			function getCandleLighting() {
				return getTimeOffset(getSeaLevelSunset(), -candleLightingOffset * Time.Gregorian.SECONDS_PER_MINUTE);
			}
			
			function getSofZmanTfila(startOfDay, endOfDay) {
				var shaahZmanit = getSpecificTemporalHour(startOfDay, endOfDay);
				return getTimeOffset(startOfDay, shaahZmanit * 4);
			}
			
			function getSofZmanTfilaGRA() {
				return getSofZmanTfila(getSeaLevelSunrise(), getSeaLevelSunset());
			}
			
			function getSofZmanTfilaMGA() {
				return getSofZmanTfila(getAlot72(), getTzait72());
			}
			
			function getSpecificMinchaGedola(startOfDay, endOfDay) {
				var shaahZmanit = getSpecificTemporalHour(startOfDay, endOfDay);
				return getTimeOffset(startOfDay, shaahZmanit * 6.5);
			}
			
			function getMinchaGedola() {
				return getSpecificMinchaGedola(getSeaLevelSunrise(), getSeaLevelSunset());
			}
			
			function getSpecificMinchaKetana(startOfDay, endOfDay) {
				var shaahZmanit = getSpecificTemporalHour(startOfDay, endOfDay);
				return getTimeOffset(startOfDay, shaahZmanit * 9.5);
			}
			
			function getMinchaKetana() {
				return getSpecificMinchaKetana(getSeaLevelSunrise(), getSeaLevelSunset());
			}
			
			function getSpecificPlagHamincha(startOfDay, endOfDay) {
				var shaahZmanit = getSpecificTemporalHour(startOfDay, endOfDay);
				return getTimeOffset(startOfDay, shaahZmanit * 10.75);
			}
			
			function getPlagHamincha() {
				return getSpecificPlagHamincha(getSeaLevelSunrise(), getSeaLevelSunset());
			}
			
			function getMisheyakir11Point5Degrees() {
				return getSunriseOffsetByDegrees(ZENITH_11_POINT_5);
			}
		}
	}
}