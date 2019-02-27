using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Time.Gregorian as Calendar;

class Logger {
	var mClassName;
	var mLogLevel = App.getApp().getProperty("LogLevel");
	
	function initialize(className) {
		Sys.println("initializing logger for " + className);
		mClassName = className;
	}
	
	function getFormattedTime() {
		var now = Time.now();
    	var time = Calendar.info(now, Time.FORMAT_SHORT);
    	
    	var day = time.day;
    	var hour = time.hour;
    	var min = time.min;
    	var month = time.month;
    	var year = time.year;
    	
		return 
			time.year + "-" + 
			time.month + "-" + 
			time.day + " " +  
			time.hour + ":" +
    		time.min + ":" +
    		time.sec;
	}

	function trace(message) {		
		if (mLogLevel == null || mLogLevel <= 3) {
			log("TRACE", message);
		}
	}

	function debug(message) {		
		if (mLogLevel == null || mLogLevel <= 2) {
			log("DEBUG", message);
		}
	}

	function info(message) {		
		if (mLogLevel == null || mLogLevel <= 1) {
			log("INFO", message);
		}
	}
	
	hidden function log(level, message) {
		var logEntry = level + " " + getFormattedTime() + " " + mClassName + ":\t" + message;
		Sys.println(logEntry);
	}
}