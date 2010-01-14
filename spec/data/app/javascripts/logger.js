/*
	  YMDP LOGGER

		Send logging messages to OIB. 
		
		Messages are saved in log/ymdp.log

*/


/* set asset version */

var LOGGER, Logger;

LOGGER = {
  VERSION: "<%= @hash %>",
  MESSAGE: "<%= @message %>",
  DEPLOYED: <%= Time.now.to_i %>,
  DEPLOYED_STRING: "<%= Time.now.to_s %>"
};

	YAHOO.namespace("logger");

	YAHOO.logger.write = function(level, message) {
		if (YAHOO.oib.login !== undefined) {
			message = "[login: " + YAHOO.oib.login + "] " + message;
		}
		if (YAHOO.oib.guid !== undefined) {
			message = "[guid: " + YAHOO.oib.guid + "] " + message;
		}
	  YAHOO.oib.callOIB("ymdp/log",
	    {
	      level: level,
	      message: message,
	      method: "POST"
	    },
	    function() {
	      // log message written successfully
	  });
	};
	
	YAHOO.logger.debug = function(message) {
	  YAHOO.logger.write("debug", message);
	};
	YAHOO.logger.info = function(message) {
	  YAHOO.logger.write("info", message);
	};
	YAHOO.logger.warn = function(message) {
	  YAHOO.logger.write("warn", message);
	};
	YAHOO.logger.error = function(message) {
	  YAHOO.logger.write("warn", message);
	};
	YAHOO.logger.fatal = function(message) {
	  YAHOO.logger.write("fatal", message);
	};
	

Logger = YAHOO.logger;	

// END YMDP LOGGER