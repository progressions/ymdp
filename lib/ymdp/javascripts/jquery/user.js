// gets user's state info from /ymdp/state
// including the user's OIB login
//
YMDP.getUserState = function(success_function, error_function) {
  Debug.log("YMDP.getUserState");
	OIB.get("ymdp/state", {}, function(response) {
	  Debug.log("YMDP.getUserState callback", response);
    YMDP.setUserVariables(response);

	  if (success_function) {
	    Debug.log("YMDP.getUserState: About to success function")
	    success_function(response);
	  }
	},
	function() {
    Debug.log("Failed to get user's state");
    if (error_function) {
      error_function();
    }
	});
};

YMDP.setUserVariables = function(response) {
  YMDP.response = response;
  try {
    YMDP.since_date = formatUnixDate(YMDP.response.since_date.s);
  } catch(omg) {
    YMDP.since_date = 1294869484;
  }
  YMDP.login = response.login;
  YMDP.state = response.state;
};

/*
	  YMDP.verifyUser

	  global to all views.  calls the 'verify' action on ymdp controller and executes
	  a function with the result.
	  
	  Sends the server the user's guid and 'ymail_wssid', which signs the user in if the
	  values match what we have in the database.
*/
YMDP.verifyUser = function(success_function, error_function) {
  Debug.log("YMDP.verifyUser");
  
  OIB.get("ymdp/verify", {
    ymail_guid: YMDP.guid,
    ymail_wssid: YMDP.ymail_wssid
  }, function(response) {
    YMDP.user = response;
    Debug.log("YMDP.verifyUser YMDP.user", YMDP.user);
    if (success_function) {
      Debug.log("YMDP.verifyUser: About to success function");
      success_function(YMDP.user);
    }
  }, error_function);
};


/*
		AUTHENTICATION
*/

// Gets the ymail_wssid which is stored in the database on the remote server
// for the current user.
//
YMDP.confirm = function() {
  Debug.log("YMDP.confirm");
  OIB.get("ymdp/signin", {
    "ymail_guid": YMDP.guid
  }, function(response) {
    Debug.log("inside ymdp/signin callback", response);
    
    if (response.ymail_wssid) {
      Debug.log("YMDP.response wasn't false");
      // store ymail_wssid in permanent store
      
      var raw_wssid = response.ymail_wssid || "";
      var sliced_wssid = raw_wssid.slice(0, 255);
      
      var data = {
        "ymail_wssid": sliced_wssid
      };
      
      Debug.log("About to call Data.store", data);
      
      Data.store(data);
      YMDP.ymail_wssid = response.ymail_wssid;
  
      // now that we've got their ymail_wssid, we can sign them in:
      YMDP.verifyUser(Launcher.launchMain);
      // Launcher.launchMain();
    } else {
      // signin didn't work properly, display an error
      Debug.log("YMDP.response was false");
      YMDP.showError({
        "method": "YMDP.confirm",
        "description": "no ymail_wssid"
      });
    }
 });
};

// gets both guid and ymail_wssid and stores them then runs the callback_function
//
// YMDP.ymail_wssid
// YMDP.guid
//
YMDP.getGuidAndYmailWssid = function(callback_function) {
  Debug.log("YMDP.getGuidAndYmailWssid");
  YMDP.getGuid(function(guid) {
   YMDP.getYmailWssid(function(ymail_wssid) {
     callback_function(guid, ymail_wssid);
   });
  });
};

// gets the ymail_wssid from the permanent store and executes the callback function
// if there is a ymail_wssid, and the error callback if it's undefined
//
// YMDP.ymail_wssid
//
YMDP.getYmailWssid = function(success_function, error_function) {
  Debug.log("YMDP.getYmailWssid");
  
  // this function will show the error page if the ymail_wssid has not been set
  //
  var show_error = function() {
    if (!YMDP.ymail_wssid) {
      Debug.log("No YMDP.ymail_wssid");
      
      YMDP.showError({
        "retry": "hide"
      });
    }
  };
  
  // run the show_error function after 5 seconds
  //
  // Debug.log("Set timeout for error function to 10 seconds");
  // YMDP.setTimeoutInSeconds(show_error, 10);
  // Debug.log("About to call Data.fetch");
  
  // retrieve the user's ymail_wssid and store it in YMDP.ymail_wssid
  //
	Data.fetch(["ymail_wssid"], function(response) {
	  Debug.log("Inside Data.fetch callback");
    YMDP.ymail_wssid = response.data.ymail_wssid;
    
	  Debug.log("YMDP.ymail_wssid is defined", YMDP.ymail_wssid);
	  
    success_function(YMDP.ymail_wssid);
	});
};

// gets the guid from the Yahoo! environment and executes the success callback
// if there is a guid, and the error callback if it's undefined
//
// YMDP.guid
//
YMDP.getGuid = function(success_function, error_function) {
  Debug.log("YMDP.getGuid");
  
  openmail.Application.getParameters(function(response) {
    Debug.log("getParameters callback");
    YMDP.guid = response.user.guid;
    
    Debug.log("YMDP.getGuid getParameters response", response);
    
    var params = {};
    if (response.data) {
      params = response.data.launchParams;
    }
    
    Params.init(params);
    
		if (YMDP.guid !== undefined) {
      success_function(YMDP.guid);
		}
		else {
			error_function();
		}
  });
};

YMDP.deactivateUser = function() {
	YMDP.getGuidAndYmailWssid(function() {
	  var guid, ymail_wssid;
	  
	  guid = YMDP.guid;
	  ymail_wssid = YMDP.ymail_wssid;

    Data.clear();

	  OIB.post("/ymdp/deactivate", {
			"ymail_guid": guid,
			"ymail_wssid": ymail_wssid
		}, 
		function(response) {
		  if (View.name !== "deactivate") {
			  Launcher.launchGoodbye();
		  }
		});
	});
};	
