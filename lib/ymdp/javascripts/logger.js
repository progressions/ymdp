/*
	  YMDP LOGGER

		Send logging messages to OIB. 
		
		Messages are saved in log/ymdp.log


  // DO NOT USE the @view instance variable in any files in /app/javascripts/base.
  // The way they are cached makes it not safe to do so.

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
		if (YAHOO.oib.login) {
			message = "[login: " + YAHOO.oib.login + "] " + message;
		}
		if (YAHOO.oib.guid) {
			message = "[guid: " + YAHOO.oib.guid + "] " + message;
		}
	  OIB.post("ymdp/log",
	    {
	      level: level,
	      message: message
	    },
	    function(response) {
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