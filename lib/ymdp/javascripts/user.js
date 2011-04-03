// gets both guid and ymail_wssid and stores them then runs the callback_function
//
// YAHOO.oib.ymail_wssid
// YAHOO.oib.guid
//
YAHOO.oib.getGuidAndYmailWssid = function(callback_function) {
  Debug.log("YAHOO.oib.getGuidAndYmailWssid");
	YAHOO.oib.getGuid(function(guid) {
		YAHOO.oib.getYmailWssid(function(ymail_wssid) {
			callback_function(guid, ymail_wssid);
		});
	});
};

// gets user's state info from /ymdp/state
// including the user's OIB login
//
YAHOO.oib.getUserState = function(success_function) {
  Debug.log("YAHOO.oib.getUserState");
	OIB.get("ymdp/state", {}, function(response) {
	  Debug.log("YAHOO.oib.getUserState callback", response);
	  YAHOO.oib.response = response;
    try {
          YAHOO.oib.since_date = formatUnixDate(YAHOO.oib.response.since_date.s);
        } catch(omg) {
          YAHOO.oib.since_date = 1294869484;
        }
	  YAHOO.oib.login = response.login;
	  YAHOO.oib.state = response.state;

	  if (success_function) {
	    Debug.log("YAHOO.oib.getUserState: About to success function")
	    success_function(response);
	  }
	},
	function() {
	  YAHOO.logger.error("Failed to get user's state");
	});
};



/*
	  YAHOO.oib.verifyUser

	  global to all views.  calls the 'verify' action on ymdp controller and executes
	  a function with the result.
*/
YAHOO.oib.verifyUser = function(success_function, error_function) {
  Debug.log("YAHOO.oib.verifyUser");
  
  OIB.get("ymdp/verify", {
    ymail_guid: YAHOO.oib.guid,
    ymail_wssid: YAHOO.oib.ymail_wssid,
    application: View.application
  }, function(response) {
    YAHOO.oib.user = response;
    Debug.log("YAHOO.oib.verifyUser YAHOO.oib.user", YAHOO.oib.user);
    if (success_function) {
      Debug.log("YAHOO.oib.verifyUser: About to success function");
      success_function(YAHOO.oib.user);
    }
  }, error_function);
};


/*
		AUTHENTICATION
*/

YAHOO.oib.signInUser = function() {
  Debug.log("YAHOO.oib.signInUser");
	OIB.get("ymdp/signin", {}, function(response) {  
	  Debug.log("inside ymdp/signin callback", response);
	  Debug.log("YAHOO.oib.response", YAHOO.oib.response);
    if (response.ymail_wssid === "false") {
      // signin didn't work properly, display an error
      Debug.log("YAHOO.oib.response was false");
      YAHOO.oib.showError({
        "method": "YAHOO.oib.signInUser",
        "description": "no ymail_wssid"
      });
    } else {
      Debug.log("YAHOO.oib.response wasn't false");
      // store ymail_wssid in permanent store
      
      var raw_wssid = response.ymail_wssid || "";
      var sliced_wssid = raw_wssid.slice(0, 255);
      
      var data = {
        "ymail_wssid": sliced_wssid
      };
      
      Debug.log("About to call Data.sore", data);
      
      Data.store(data);
      YAHOO.oib.ymail_wssid = response.ymail_wssid;
  
      YAHOO.oib.verifyUser(YAHOO.launcher.launchMain);
    }
	});
};


// gets the guid from the Yahoo! environment and executes the success callback
// if there is a guid, and the error callback if it's undefined
//
// YAHOO.oib.guid
//
YAHOO.oib.getGuid = function(success_function, error_function) {
  Debug.log("YAHOO.oib.getGuid");
  
  openmail.Application.getParameters(function(response) {
    YAHOO.oib.guid = response.user.guid;
    try {
      Debug.log("YAHOO.oib.getGuid getParameters response", response);
      
      var params = {};
      if (response.data) {
        params = response.data.launchParams;
      }
      Params.init(params);
    } catch(omg) {
      Debug.error("error getting parameters: " + omg);
    }
		if (YAHOO.oib.guid !== undefined) {
    	Try.these(
				function() { success_function(YAHOO.oib.guid); }
			);
		}
		else {
			Try.these(error_function);
		}
  });
};


// gets the ymail_wssid from the permanent store and executes the callback function
// if there is a ymail_wssid, and the error callback if it's undefined
//
// YAHOO.oib.ymail_wssid
//
YAHOO.oib.getYmailWssid = function(success_function, error_function) {
  Debug.log("YAHOO.oib.getYmailWssid");
  
  // this function will show the error page if the ymail_wssid has not been set
  //
  var show_error = function() {
    if (YAHOO.oib.ymail_wssid === undefined) {
      Debug.log("No YAHOO.oib.ymail_wssid");
      
      YAHOO.oib.showError({
        "retry": "hide"
      });
    } else {
      Debug.log("YAHOO.oib.ymail_wssid does exist", YAHOO.oib.ymail_wssid);
    }
  };
  
  // run the show_error function after 5 seconds
  //
  Debug.log("Set timeout for error function to 5 seconds");
  YAHOO.oib.setTimeoutInSeconds(show_error, 5);
  Debug.log("About to call Data.fetch");
  
  // retrieve the user's ymail_wssid and store it in YAHOO.oib.ymail_wssid
  //
	Data.fetch(["ymail_wssid"], function(response) {
	  Debug.log("Inside Data.fetch callback");
    YAHOO.oib.ymail_wssid = response.data.ymail_wssid;
		if (YAHOO.oib.ymail_wssid !== undefined) {
		  Debug.log("YAHOO.oib.ymail_wssid is defined", YAHOO.oib.ymail_wssid);
		  
		  try {
        success_function(YAHOO.oib.ymail_wssid);
		  } catch(omg) {
		    Debug.error("Error in YAHOO.oib.getYmailWssid getData callback", omg);
		  }
		  
		}
		else {
			Try.these(error_function);
		}
	});
};

YAHOO.oib.deactivateUser = function() {
	YAHOO.oib.getGuidAndYmailWssid(function() {
	  var guid, ymail_wssid;
	  
	  guid = YAHOO.oib.guid;
	  ymail_wssid = YAHOO.oib.ymail_wssid;

    Data.clear();

	  OIB.post("/ymdp/deactivate", {
			"ymail_guid": guid,
			"ymail_wssid": ymail_wssid
		}, 
		function(response) {
      // YAHOO.logger.info("Finished deactivating user");
		  if (View.name !== "deactivate") {
			  YAHOO.launcher.launchGoodbye();
		  }
		});
	});
};	
