using Toybox.Time as Time;

module JewishCalendarModule {
	module HebrewCalendar
	{
		class JewishDate
		{
			hidden static const JEWISH_YEAR = 5775;
			static const NISSAN = 1;
			static const IYAR = 2;
			static const SIVAN = 3;
			static const TAMMUZ = 4;
			static const AV = 5;
			static const ELUL = 6;
			static const TISHREI = 7;
			static const CHESHVAN = 8;
			static const KISLEV = 9;
			static const TEVES = 10;
			static const SHEVAT = 11;
			static const ADAR = 12;
			static const ADAR_II = 13;
		
			hidden static const JEWISH_EPOCH = -1373429;
			hidden static const DAY_FORWARD_DURATION = new Time.Duration(24 * 60 * 60);
			
			hidden var gregorianMonth, gregorianDayOfMonth, gregorianYear, gregorianAbsDate, dayOfWeek;
			hidden var jewishYear, jewishMonth, jewishDay;			
		
			hidden static const ELAPSED_DAYS_FOR_YEAR = {5776 => 2109283,5777 => 2109668,5778 => 2110021,5779 => 2110375,5780 => 2110760,5781 => 2111115,5782 => 2111468,5783 => 2111852,5784 => 2112207,5785 => 2112590,5786 => 2112945,5787 => 2113299,5788 => 2113684,5789 => 2114039,5790 => 2114393,5791 => 2114776,5792 => 2115131,5793 => 2115485,5794 => 2115868,5795 => 2116223};
		
			function initialize(moment, tzeit)
			{
				setDate(moment, tzeit);
			}
		
			function setDate(calendar, tzeit)
			{
				if (calendar.greaterThan(tzeit)) {
					calendar = calendar.add(DAY_FORWARD_DURATION);
				}
				var calendarInfo = Time.Gregorian.info(calendar, Time.FORMAT_SHORT);
				gregorianMonth = calendarInfo.month;
				gregorianDayOfMonth = calendarInfo.day;
				gregorianYear = calendarInfo.year;
				dayOfWeek = calendarInfo.day_of_week;
				gregorianAbsDate = gregorianDateToAbsDate(gregorianYear, gregorianMonth, gregorianDayOfMonth); // init the date
				absDateToJewishDate();
			}
			
			function getJewishYear() {
				return jewishYear;
			}
			
			function getJewishMonth() {
				return jewishMonth;
			}
			
			function getJewishDay() {
				return jewishDay;
			}
			
			hidden static function gregorianDateToAbsDate(year, month, dayOfMonth) {
				var absDate = dayOfMonth;
				for (var m = month - 1; m > 0; m--) {
					absDate += getLastDayOfGregorianMonth(m, year); // days in prior months of the year
				}
				return (absDate // days this year
						+ 365 * (year - 1) // days in previous years ignoring leap days
						+ (year - 1) / 4 // Julian leap days before this year
						- (year - 1) / 100 // minus prior century years
				+ (year - 1) / 400); // plus prior years divisible by 400
			}
			
			hidden static function getLastDayOfGregorianMonth(month, year)
			{
				if (month == 2)
				{
					if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
						return 29;
					} else {
						return 28;
					}
				}
				else if (month == 4 || month == 6 || month == 9 || month == 11)
				{
					return 30;
				}
				
				return 31;
			}
			
			hidden function absDateToJewishDate() {
				// Approximation from below
				jewishYear = JEWISH_YEAR;
				// Search forward for year from the approximation
				//jewishDateToAbsDate(jewishYear + 1, TISHREI, 1);
				while (gregorianAbsDate >= jewishDateToAbsDate(jewishYear + 1, TISHREI, 1)) {
					jewishYear++;
				}
				// Search forward for month from either Tishri or Nisan.
				if (gregorianAbsDate < jewishDateToAbsDate(jewishYear, NISSAN, 1)) {
					jewishMonth = TISHREI;// Start at Tishri
				} else {
					jewishMonth = NISSAN;// Start at Nisan
				}
				while (gregorianAbsDate > jewishDateToAbsDate(jewishYear, jewishMonth, getDaysInThisJewishMonth())) {
					jewishMonth++;
				}
				// Calculate the day by subtraction
				jewishDay = gregorianAbsDate - jewishDateToAbsDate(jewishYear, jewishMonth, 1) + 1;
				//Logger.debug ("JewishDate","absDateToJewishDate","jewishDay: "+gregorianAbsDate+" "+ jewishDateToAbsDate(jewishYear, jewishMonth, 1));
			}
			
			hidden static function jewishDateToAbsDate(year, month, dayOfMonth) {
				//Logger.debug ("JewishDate","jewishDateToAbsDate","year " +year+ "month" +month + "dayOfMonth"+ dayOfMonth);
				var elapsed = getDaysSinceStartOfJewishYear(year, month, dayOfMonth);
				//Logger.debug ("JewishDate","jewishDateToAbsDate","elapsed "+elapsed);
				// add elapsed days this year + Days in prior years + Days elapsed before absolute year 1
				//Logger.debug ("JewishDate","jewishDateToAbsDate","JEWISH_EPOCH " + JEWISH_EPOCH);
				//Logger.debug ("JewishDate","jewishDateToAbsDate","getJewishCalendarElapsedDays" + getJewishCalendarElapsedDays(year));
				return elapsed + getJewishCalendarElapsedDays(year) + JEWISH_EPOCH;
			}
			
			hidden static function getDaysSinceStartOfJewishYear(year, month, dayOfMonth) {
				var elapsedDays = dayOfMonth;
				// Before Tishrei (from Nissan to Tishrei), add days in prior months
				if (month < TISHREI) {	
					//Logger.debug ("JewishDate","getDaysSinceStartOfJewishYear","less than tishrei");
					// this year before and after Nisan.
					for (var m = TISHREI; m <= getLastMonthOfJewishYear(year); m++) {
						elapsedDays += getDaysInJewishMonth(m, year);
					}
					for (var m = NISSAN; m < month; m++) {
						elapsedDays += getDaysInJewishMonth(m, year);
					}
				} else { // Add days in prior months this year
					for (var m = TISHREI; m < month; m++) {
						elapsedDays += getDaysInJewishMonth(m, year);
					}
				}
				return elapsedDays;
			}
			
			static function getLastMonthOfJewishYear(year) {
				return isJewishLeapYear(year) ? ADAR_II : ADAR;
			}
			
			static function getJewishCalendarElapsedDays(year) {
				var elapsedDays = ELAPSED_DAYS_FOR_YEAR[year];
				if (elapsedDays == null) {
					elapsedDays = -1;
				}
				return elapsedDays;
			}
					
			hidden static function getDaysInJewishMonth(month, year) {
				//Logger.debug ("JewishDate","getDaysInJewishMonth"," month: " +month + " year: "+year + " cheshvan long: "+isCheshvanLong(year) + " kisshort: "+isKislevShort(year)+" JLY "+isJewishLeapYear(year));
				if ((month == IYAR) || (month == TAMMUZ) || (month == ELUL) || ((month == CHESHVAN) && !(isCheshvanLong(year)))
						|| ((month == KISLEV) && isKislevShort(year)) || (month == TEVES)
						|| ((month == ADAR) && !(isJewishLeapYear(year))) || (month == ADAR_II)) {
					//Logger.debug ("JewishDate","getDaysInJewishMonth","getDaysInJewishMOnth:  29");
					return 29;
				} else {
					//Logger.debug ("JewishDate","getDaysInJewishMonth","getDaysInJewishMOnth:  30");
					return 30;
				}
			}
			
			hidden static function getDaysInThisJewishMonth() {
				return getDaysInJewishMonth(getJewishMonth(), getJewishYear());
			}
			
			hidden static function isCheshvanLong(year) {
				return getDaysInJewishYear(year) % 10 == 5;
			}
			
			hidden static function getDaysInJewishYear(year) {
				//Logger.debug ("JewishDate","getDaysInJewishYear","year: "+year);
				return getJewishCalendarElapsedDays(year + 1) - getJewishCalendarElapsedDays(year);
			}
			
			hidden static function isKislevShort(year) {
				//Logger.debug ("JewishDate","isKislevShort","year: "+year);
				return getDaysInJewishYear(year) % 10 == 3;
			}
			
			function isThisKislevShort() {
				//Logger.debug ("JewishDate","isThisKislevShort","year: "+getJewishYear());
				return isKislevShort(getJewishYear());
			}
			
			hidden static function getJewishMonthOfYear(year, month) {
				var isLeapYear = isJewishLeapYear(year);
				return (month + (isLeapYear ? 6 : 5)) % (isLeapYear ? 13 : 12) + 1;
			}
			
			hidden static function isJewishLeapYear(year) {
				return ((7 * year) + 1) % 19 < 7;
			}
			
			function isThisJewishLeapYear() {
				return isJewishLeapYear(getJewishYear());
			}
		}
		
		class JewishCalendar extends JewishDate
		{
			static const EREV_PESACH = 0;
			static const PESACH = 1;
			static const CHOL_HAMOED_PESACH = 2;
			static const PESACH_SHENI = 3;
			static const EREV_SHAVUOS = 4;
			static const SHAVUOS = 5;
			static const SEVENTEEN_OF_TAMMUZ = 6;
			static const TISHA_BEAV = 7;
			static const TU_BEAV = 8;
			static const EREV_ROSH_HASHANA = 9;
			static const ROSH_HASHANA = 10;
			static const FAST_OF_GEDALYAH = 11;
			static const EREV_YOM_KIPPUR = 12;
			static const YOM_KIPPUR = 13;
			static const EREV_SUCCOS = 14;
			static const SUCCOS = 15;
			static const CHOL_HAMOED_SUCCOS = 16;
			static const HOSHANA_RABBA = 17;
			static const SHEMINI_ATZERES = 18;
			static const SIMCHAS_TORAH = 19;
			// static const EREV_CHANUKAH = 20;// probably remove this
			static const CHANUKAH = 21;
			static const TENTH_OF_TEVES = 22;
			static const TU_BESHVAT = 23;
			static const FAST_OF_ESTHER = 24;
			static const PURIM = 25;
			static const SHUSHAN_PURIM = 26;
			static const PURIM_KATAN = 27;
			static const ROSH_CHODESH = 28;
			static const YOM_HASHOAH = 29;
			static const YOM_HAZIKARON = 30;
			static const YOM_HAATZMAUT = 31;
			static const YOM_YERUSHALAYIM = 32;		
		
			hidden var inIsrael = true;
			hidden var useModernHolidays = true;
		
			function initialize(moment, tzeit)
			{			
	    		JewishDate.initialize(moment, tzeit);    		
			}
			
			function setUseModernHolidays(setUseModernHolidays) {
				useModernHolidays = setUseModernHolidays;
			}
			
			function setInIsrael(setInIsrael) {
				inIsrael = setInIsrael;
				//Logger.info("JewishCalendar","setInIsrael", setInIsrael);
			}
		
			/**
			 * Returns an index of the Jewish holiday or fast day for the current day, or a null if there is no holiday for this
			 * day.
			 * 
			 */
			function getYomTovIndex() {
				// check by month (starts from Nissan)
				if (jewishMonth == NISSAN) {
					if (jewishDay == 14) {
						return EREV_PESACH;
					} else if (getJewishDay() == 15 || getJewishDay() == 21
							|| (!inIsrael && (getJewishDay() == 16 || getJewishDay() == 22))) {
						return PESACH;
					} else if (getJewishDay() >= 17 && getJewishDay() <= 20
							|| (getJewishDay() == 16 && inIsrael)) {
						return CHOL_HAMOED_PESACH;
					}
					if (useModernHolidays
							&& ((getJewishDay() == 26 && dayOfWeek == 5)
									|| (getJewishDay() == 28 && dayOfWeek == 1)
									|| (getJewishDay() == 27 && dayOfWeek == 3) || (getJewishDay() == 27 && dayOfWeek == 5))) {
						return YOM_HASHOAH;
					}
				} else if (jewishMonth == IYAR) {
					if (useModernHolidays
							&& ((getJewishDay() == 4 && dayOfWeek == 3)
									|| ((getJewishDay() == 3 || getJewishDay() == 2) && dayOfWeek == 4) || (getJewishDay() == 5 && dayOfWeek == 2))) {
						return YOM_HAZIKARON;
					}
					// if 5 Iyar falls on Wed Yom Haatzmaut is that day. If it fal1s on Friday or Shabbos it is moved back to
					// Thursday. If it falls on Monday it is moved to Tuesday
					if (useModernHolidays
							&& ((getJewishDay() == 5 && dayOfWeek == 4)
									|| ((getJewishDay() == 4 || getJewishDay() == 3) && dayOfWeek == 5) || (getJewishDay() == 6 && dayOfWeek == 3))) {
						return YOM_HAATZMAUT;
					}
					if (getJewishDay() == 14) {
						return PESACH_SHENI;
					}
					if (useModernHolidays && getJewishDay() == 28) {
						return YOM_YERUSHALAYIM;
					}
				} else if (jewishMonth == SIVAN) {
					if (getJewishDay() == 5) {
						return EREV_SHAVUOS;
					} else if (getJewishDay() == 6 || (getJewishDay() == 7 && !inIsrael)) {
						return SHAVUOS;
					}
				} else if (jewishMonth == TAMMUZ) {
					// push off the fast day if it falls on Shabbos
					if ((getJewishDay() == 17 && dayOfWeek != 7)
							|| (getJewishDay() == 18 && dayOfWeek == 1)) {
						return SEVENTEEN_OF_TAMMUZ;
					}
				} else if (jewishMonth == AV) {
					// if Tisha B'av falls on Shabbos, push off until Sunday
					if ((dayOfWeek == 1 && getJewishDay() == 10)
							|| (dayOfWeek != 7 && getJewishDay() == 9)) {
						return TISHA_BEAV;
					} else if (getJewishDay() == 15) {
						return TU_BEAV;
					}
				} else if (jewishMonth == ELUL) {
					if (getJewishDay() == 29) {
						return EREV_ROSH_HASHANA;
					}
				} else if (jewishMonth == TISHREI) {
					if (getJewishDay() == 1 || getJewishDay() == 2) {
						return ROSH_HASHANA;
					} else if ((getJewishDay() == 3 && dayOfWeek != 7)
							|| (getJewishDay() == 4 && dayOfWeek == 1)) {
						// push off Tzom Gedalia if it falls on Shabbos
						return FAST_OF_GEDALYAH;
					} else if (getJewishDay() == 9) {
						return EREV_YOM_KIPPUR;
					} else if (getJewishDay() == 10) {
						return YOM_KIPPUR;
					} else if (getJewishDay() == 14) {
						return EREV_SUCCOS;
					}
					if (getJewishDay() == 15 || (getJewishDay() == 16 && !inIsrael)) {
						return SUCCOS;
					}
					if (getJewishDay() >= 17 && getJewishDay() <= 20 || (getJewishDay() == 16 && inIsrael)) {
						return CHOL_HAMOED_SUCCOS;
					}
					if (getJewishDay() == 21) {
						return HOSHANA_RABBA;
					}
					if (getJewishDay() == 22) {
						return SHEMINI_ATZERES;
					}
					if (getJewishDay() == 23 && !inIsrael) {
						return SIMCHAS_TORAH;
					}
				} else if (jewishMonth == KISLEV) 
				{ // no yomtov in CHESHVAN
					// if (getJewishDay() == 24) {
					// return EREV_CHANUKAH;
					// } else
					if (getJewishDay() >= 25) {
						return CHANUKAH;
					}
				} else if (jewishMonth == TEVES) {
					if (getJewishDay() == 1 || getJewishDay() == 2
							|| (getJewishDay() == 3 && JewishDate.isThisKislevShort())) {
						return CHANUKAH;
					} else if (getJewishDay() == 10) {
						return TENTH_OF_TEVES;
					}
				} else if (jewishMonth == SHEVAT) {
					if (getJewishDay() == 15) {
						return TU_BESHVAT;
					}
				} else if (jewishMonth == ADAR) {
					if (!JewishDate.isThisJewishLeapYear()) {
						// if 13th Adar falls on Friday or Shabbos, push back to Thursday
						if (((getJewishDay() == 11 || getJewishDay() == 12) && dayOfWeek == 5)
								|| (getJewishDay() == 13 && !(dayOfWeek == 6 || dayOfWeek == 7))) {
							return FAST_OF_ESTHER;
						}
						if (getJewishDay() == 14) {
							return PURIM;
						} else if (getJewishDay() == 15) {
							return SHUSHAN_PURIM;
						}
					} else { // else if a leap year
						if (getJewishDay() == 14) {
							return PURIM_KATAN;
						}
					}
				} else if (jewishDay == ADAR_II) {
					// if 13th Adar falls on Friday or Shabbos, push back to Thursday
					if (((getJewishDay() == 11 || getJewishDay() == 12) && dayOfWeek == 5)
							|| (getJewishDay() == 13 && !(dayOfWeek == 6 || dayOfWeek == 7))) {
						return FAST_OF_ESTHER;
					}
					if (getJewishDay() == 14) {
						return PURIM;
					} else if (getJewishDay() == 15) {
						return SHUSHAN_PURIM;
					}
				}
				// if we get to this stage, then there are no holidays for the given date return -1
				return -1;
			}
			
			function isYomTov() {
				var holidayIndex = getYomTovIndex();
				if (isErevYomTov() || holidayIndex == CHANUKAH || (isTaanis() && holidayIndex != YOM_KIPPUR)) {
					return false;
				}
				return holidayIndex != -1;
			}
	
			function isCholHamoed() {
				var holidayIndex = getYomTovIndex();
				return holidayIndex == CHOL_HAMOED_PESACH || holidayIndex == CHOL_HAMOED_SUCCOS;
			}
		
			function isErevYomTov() {
				var holidayIndex = getYomTovIndex();
				return holidayIndex == EREV_PESACH || holidayIndex == EREV_SHAVUOS || holidayIndex == EREV_ROSH_HASHANA
						|| holidayIndex == EREV_YOM_KIPPUR || holidayIndex == EREV_SUCCOS;
			}
			
			function isErevShabbat() {
				return dayOfWeek == 6;
			}
		
			function isErevRoshChodesh() {
				// Erev Rosh Hashana is not Erev Rosh Chodesh.
				return (getJewishDay() == 29 && getJewishMonth() != ELUL);
			}
		
			function isTaanis() {
				var holidayIndex = getYomTovIndex();
				return holidayIndex == SEVENTEEN_OF_TAMMUZ || holidayIndex == TISHA_BEAV || holidayIndex == YOM_KIPPUR
						|| holidayIndex == FAST_OF_GEDALYAH || holidayIndex == TENTH_OF_TEVES || holidayIndex == FAST_OF_ESTHER;
			}
		
			function getDayOfChanukah() {
				if (isChanukah()) {
					if (getJewishMonth() == KISLEV) {
						return getJewishDay() - 24;
					} else { // teves
						return isKislevShort() ? getJewishDay() + 5 : getJewishDay() + 6;
					}
				} else {
					return -1;
				}
			}
		
			function isChanukah() {
				return getYomTovIndex() == CHANUKAH;
			}	
		
			function isRoshChodesh() {
				// Rosh Hashana is not rosh chodesh. Elul never has 30 days
				return (getJewishDay() == 1 && getJewishMonth() != TISHREI) || getJewishDay() == 30;
			}
		
			function getDayOfOmer() {
				var omer = -1; // not a day of the Omer
		
				// if Nissan and second day of Pesach and on
				if (getJewishMonth() == NISSAN && getJewishDay() >= 16) {
					omer = getJewishDay() - 15;
					// if Iyar
				} else if (getJewishMonth() == IYAR) {
					omer = getJewishDay() + 15;
					// if Sivan and before Shavuos
				} else if (getJewishMonth() == SIVAN && getJewishDay() < 6) {
					omer = getJewishDay() + 44;
				}
				return omer;
			}
		}
	}
}
