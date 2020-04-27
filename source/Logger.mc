module JewishCalendarModule {
	class Logger
	{
		static var DEBUG = false;
		static var INFO = true;
	
		static function setDebug(debug){
			DEBUG = debug;
		}
		
		static function debug (clazz, method, message) {
			if (DEBUG == true) {
				Toybox.System.println("DEBUG: "+clazz+";"+method+";"+message);
			}
		}
		
		static function setInfo(info){
			INFO = info;
		}
		
		static function info (clazz, method, message) {
			if (INFO == true) {
				Toybox.System.println("INFO: "+clazz+";"+method+";"+message);
			}
		}
	}
}