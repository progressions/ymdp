/*
	APPLICATION

*/

var APPLICATION, Browser, OIB;

/* set asset version */
APPLICATION = {
  VERSION: "<%= @hash %>",
  MESSAGE: "<%= @message %>",
  DEPLOYED: <%= Time.now.to_i %>,
  DEPLOYED_STRING: "<%= Time.now.to_s %>"
};



/* 
	GLOBAL CONSTANTS 
*/

YAHOO.namespace("oib");
YAHOO.namespace("constants");
YAHOO.namespace("images");

YAHOO.constants.states = ["nil", "authorized", "inspect", "new_active", "processing", "active", "inactive", "invalid", "maintenance"];

/*
  Authorze/Reauthorize NAMESPACES/CONSTANTS
*/

  YAHOO.constants.check_user_interval = 3;
  YAHOO.constants.error_timeout = 60;

Browser = {
  version: function(v) {
    var version, app_version;
    app_version = navigator.appVersion;
  
    if (app_version.match("MSIE 6.0")) {
      version = 6.0;
    }
  
    if (v) {
      return (version === v);
    } else {
      return version;
    }
  },

  ie: function() {
    return navigator.appName.match("Internet Explorer");
  },

  ie6: function() {
    return (Browser.ie() && Browser.version(6.0));
  },

  ie7: function() {
    return (Browser.ie() && Browser.version(7.0));
  },

  ie8: function() {
    return (Browser.ie() && Browser.version(8.0));
  }
};


function unixTimeToDate(unixtime) {
  return new Date(unixtime * 1000);
}

function formatUnixDate(unixtime) {
  var date;
  date = unixTimeToDate(unixtime);
  return date.toString("MMMM d, yyyy");
}

Try.these(function() {

/*
	  CALL OIB

	  global to every view.  sends Ajax call to OtherInbox.
*/

	// send an Ajax call to OtherInbox.
	// takes as parameters:
	// - the path to call
	// - any additional query string params
	// - a callback function to run when the Ajax call is a success
	// - an optional error function
	// - a base URL to use, if you don't want this call going to YAHOO.constants.base_url
	// TODO refactor this function to take a second params hash where we could stick success_function, error_function, and base_url

	YAHOO.oib.callOIB = function(oib_path, params, success_function, error_function, base_url) {
	  Debug.log("inside YAHOO.oib.call: ", {
	    "oib_path": oib_path,
	    "params": Object.toJSON(params)
	  });
	  var oib_url, method;
	  
	  oib_url = base_url ? base_url : YAHOO.constants.base_url;
	  
	  if (!(oib_path && typeof(oib_path) === "string")) {
	    throw("YAHOO.oib.callOIB must define oib_path");
	  }
	  if (!(params && typeof(params) === "object")) {
	    throw("YAHOO.oib.callOIB must define params");
	  }
	  
	 	oib_url = oib_url + oib_path;
	  method = "GET";
	  if (!params.format) {
	    params.format = 'json';
	  }
	  if (params.method) {
	    method = params.method;
	    delete params.method;
	  }
	  params.version = params.version || <%= @version %>;
		Try.these(function() {
		  Debug.log("About to openmail.Application.callWebService: ", {
		    "url": oib_url + "?" + Object.toQueryString(params)
		  });
			openmail.Application.callWebService(
			{
				url: oib_url,
				method: method,
				parameters: params
			},
			function(response) {
			  if (response.error) {
			    Debug.ajaxError("Error in YAHOO.oib.callOIB", oib_url, params, response);
			    if (error_function) {
					  error_function(response);
					} else {
            OIB.error(oib_url, params, response);
          }
			  } else {
					Try.these(function() {
			    	success_function(response);
					});
			  }
			});
		});
	};

});

OIB = {
	get: function(oib_path, params, success_function, error_function, base_url) {
		params.method = "GET";
		OIB.call(oib_path, params, success_function, error_function, base_url);
	},

	post: function(oib_path, params, success_function, error_function, base_url) {
		params.method = "POST";
		OIB.call(oib_path, params, success_function, error_function, base_url);
	},
	
	call: function(oib_path, params, success_function, error_function, base_url) {
	  var success;
	  
	  success = function(response) {
      response = YAHOO.lang.JSON.parse(response.data);
      if (response.error) {
        error_function(response);
      } else {
        success_function(response); 
      }
    };
	  YAHOO.oib.callOIB(oib_path, params, success, error_function, base_url);
	},
	
  // overwrite this function locally if you need to
	error: function(url, params, response) {
	  var message;
	  
	  message = "OIB.error: " + Object.toJSON(response) + " calling url: " + url + "?" + Object.toQueryString(params);
	  Debug.error(message);
    // Logger.error(message);
	}
};


YAHOO.oib.showError = function() {
  $('main').hide();
  $('utility').show();
	$('loading').hide();
	$('error').show();
};

YAHOO.oib.showLoading = function() {
  $('main').hide();
  $('utility').show();
  $('error').hide();
  $('loading').show();
};

Try.these(function() {

	// gets the guid from the Yahoo! environment and executes the success callback
	// if there is a guid, and the error callback if it's undefined
	//
	// YAHOO.oib.guid
	//
	YAHOO.oib.getGuid = function(success_function, error_function) {
	  openmail.Application.getParameters(function(response) {
	    YAHOO.oib.guid = response.user.guid;
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
});

Try.these(function() {

	// gets the ymail_wssid from the permanent store and executes the callback function
	// if there is a ymail_wssid, and the error callback if it's undefined
	//
	// YAHOO.oib.ymail_wssid
	//
	YAHOO.oib.getYmailWssid = function(success_function, error_function) {
		openmail.Application.getData({keys: ["ymail_wssid"]}, function(response) {
	  	YAHOO.oib.ymail_wssid = response.data.ymail_wssid;
			if (YAHOO.oib.ymail_wssid !== undefined) {
				Try.these(
					function() { success_function(YAHOO.oib.ymail_wssid); }
				);
			}
			else {
				Try.these(error_function);
			}
		});
	};

});

Try.these(function() {

	// gets both guid and ymail_wssid and stores them then runs the callback_function
	//
	// YAHOO.oib.ymail_wssid
	// YAHOO.oib.guid
	//
	YAHOO.oib.getGuidAndYmailWssid = function(callback_function) {
		YAHOO.oib.getGuid(function(guid) {
			YAHOO.oib.getYmailWssid(function(ymail_wssid) {
				Try.these(
					function() {callback_function(guid, ymail_wssid); }
				);
			});
		});
	};


});

Try.these(function() {

	// gets user's state info from /ymdp/state
	// including the user's OIB login
	//
	YAHOO.oib.getUserState = function(success_function) {
		YAHOO.oib.callOIB("ymdp/state", {}, function(response) {
		  response = YAHOO.lang.JSON.parse(response.data);
		  YAHOO.oib.response = response;
		  YAHOO.oib.login = response.login;
		  YAHOO.oib.state = response.state;

		  if (success_function !== undefined) {
		    success_function(response);
		  }
		},
		function() {
		  YAHOO.logger.error("Failed to get user's state");
		});
	};


});

Try.these(function() {

/*
	  YAHOO.oib.verifyUser

	  global to all views.  calls the 'verify' action on ymdp controller and executes
	  a function with the result.
*/
	YAHOO.oib.verifyUser = function(success_function) {
	  YAHOO.oib.callOIB("ymdp/verify", {
	    ymail_guid: YAHOO.oib.guid,
	    ymail_wssid: YAHOO.oib.ymail_wssid
	  }, function(response) {
	       YAHOO.oib.user = YAHOO.lang.JSON.parse(response.data);
	       if (success_function !== undefined) {
	         success_function(YAHOO.oib.user);
	       }
	  });
	};


/*
		AUTHENTICATION

*/

});

Try.these(function() {

	YAHOO.oib.signInUser = function() {
		YAHOO.oib.callOIB("ymdp/signin", {}, function(response) {
	    YAHOO.oib.response = YAHOO.lang.JSON.parse(response.data);
  
	    if (YAHOO.oib.response.ymail_wssid === "false") {
	      // signin didn't work properly, display an error
	      YAHOO.showError();
	    } else {
	      // store ymail_wssid in permanent store
	      openmail.Application.setData({keys : {ymail_wssid: YAHOO.oib.response.ymail_wssid}});
	      YAHOO.oib.ymail_wssid = YAHOO.oib.response.ymail_wssid;
    
	      YAHOO.oib.verifyUser(YAHOO.launcher.launchSettings);
	    }
		});
	};

});

	YAHOO.oib.clearPermanentStore = function() {
	  openmail.Application.setData({keys : {ymail_wssid: null}});
	  YAHOO.oib.guid = null;
	  YAHOO.oib.ymail_wssid = null;
	};


	YAHOO.oib.setTimeoutInSeconds = function(callback_function, interval) {
		setTimeout(callback_function, interval * 1000);
	};
		
	YAHOO.oib.deactivateUser = function() {
		YAHOO.oib.getGuidAndYmailWssid(function() {
		  var guid, ymail_wssid;
		  
		  guid = YAHOO.oib.guid;
		  ymail_wssid = YAHOO.oib.ymail_wssid;
  
			YAHOO.oib.clearPermanentStore();

		  OIB.post("/ymdp/deactivate", {
				ymail_guid: guid,
				ymail_wssid: ymail_wssid
			}, 
			function(response) {
        // YAHOO.logger.info("Finished deactivating user");
			  if ("<%= @view %>" !== "deactivate") {
  			  YAHOO.launcher.launchGoodbye();
  		  }
			});
		});
	};	


YAHOO.oib.submitForm = function(url, form_name, success_function, error_function) {
	Try.these(function() {
   $('submit_link').hide();
   $('submit_spinner').show();
  });
  
  var form_id, params;

	form_id = form_name + "_form";

  params = {};
  params["method"] = "POST";
	params[form_name] = Object.toJSON($(form_id).serialize(true));

  YAHOO.oib.callOIB(url, params, success_function,
		function(response) {
			Try.these(function() {
				$('submit_spinner').hide();
				$('submit_link').show();
			});

			YAHOO.flash.t.error('PROBLEM_SUBMITTING', 'settings');
			YAHOO.logger.error("Error submitting params: " + Object.toJSON(params) + " Error: " + Object.toJSON(response.error));
     }
   );
	return false;
};


YAHOO.oib.showTranslations = function() {
  Debug.log("begin YAHOO.oib.showTranslations");
	Try.these(YAHOO.init.translateToolbar);
	Try.these(YAHOO.init.translateFooter);
	Try.these(I18n.findAndTranslateAll);

	// define I18n.localTranslations in the view template
	Try.these(I18n.localTranslations);
	
  Debug.log("end YAHOO.oib.showTranslations");
};

/* 

INITIALIZER CODE

*/

YAHOO.namespace("init");

// Adds behaviors/observers to elements on the page
//
YAHOO.init.addBehaviors = function() {
	// overwrite this function locally
};

// hide the loading screen and show the main body of the summary
YAHOO.init.show = function() {
  $('utility').hide();
  $('error').hide();
	$('loading').hide();
  $('main').show();
};


// Local initializer.  When your page starts up, this method will be called after fetching the user's guid and ymail wssid.
//
YAHOO.init.local = function() {
  alert("This hasn't been overwritten.");
	// overwrite this function locally
};

// To be run before any other initializers have run.
//
YAHOO.init.before = function() {
	// overwrite this function locally
};

// Main startup code. Overwrite this function to execute after YAHOO.init.before and before YAHOO.init.after.
//
YAHOO.init.startup = function() {
  Debug.log("init.startup");
	// gets the user
	YAHOO.oib.getGuid(function(guid) {
	  Debug.log("inside getGuid callback");
	  YAHOO.oib.getUserState(function(response) {
	    Debug.log("inside getUserState callback");
      Try.these(YAHOO.init.local);
	  });
	});
};

YAHOO.init.abTesting = function() {
  // to enable abTesting in your view, overwrite this file locally.
  // 
  // be sure to finish your post-Ajax callback with YAHOO.init.show()
  //
  Try.these(YAHOO.init.show);
	Try.these(YAHOO.init.after);
};

// Finishing code. Runs after startup, executes translations and behaviors.  Shows the page and then 
// runs the A/B testing callback, which in turn will execute the last callbacks.
//
YAHOO.init.finish = function() {
  Debug.info("init.finish for view <%= @view %>");
	Try.these(YAHOO.oib.showTranslations);
	Try.these(YAHOO.init.addBehaviors);
  Try.these(YAHOO.init.abTesting);
  YAHOO.oib.page_loaded = true;
  Debug.info("finished init.finish for view <%= @view %>");
};

// Post-initalizer. Very last thing that runs, after content has been shown.
//
YAHOO.init.after = function() {
	// overwrite this function locally
};

// Execute the before, startup and after methods. Do not overwrite. (Change YAHOO.init.startup to create a custom initializer.)
YAHOO.oib.init = function() {
  // Debug.profile("loading");
  Debug.info("OIB.init for view <%= @view %>", "<%= @message %>");
  try {
    YAHOO.init.resources();
    I18n.addLanguageToBody();
    I18n.translateLoading();
    I18n.translateError();
    YAHOO.init.before();
    YAHOO.init.startup();
  } catch(err_f) {
    YAHOO.oib.showError();
    Debug.error("Error in YAHOO.oib.init", err_f);
  }
};

YAHOO.init.resources = function() {
  Debug.log("about to call I18n.setResources");

  I18n.assets_path = "<%= @assets_path %>/yrb";

  I18n.availableLanguages = <%= supported_languages.to_json %>;

  I18n.currentLanguage = OpenMailIntl.findBestLanguage(I18n.availableLanguages);
  
  I18n.setResources();

  Debug.log("finished calling I18n.setResources");
};

// Contains the last two callbacks, to show the page contents and run post-show function.  Do not overwrite.
YAHOO.init.showAndFinish = function() {
  Debug.log("YAHOO.init.showAndFinish");
  YAHOO.init.show();
  YAHOO.init.after();
};

YAHOO.init.translateToolbar = function() {
  Debug.log("begin YAHOO.init.translateToolbar");
  Try.these(function() {
    I18n.update('help_link', 'HELP');
    I18n.update('settings_link', 'SETTINGS');
    I18n.update('identity_link', 'IDENTITY');
  });
	Try.these(YAHOO.init.translateGreeting);
	Try.these(YAHOO.init.translateSubhead);
  Debug.log("end YAHOO.init.translateToolbar");
};

YAHOO.init.translateGreeting = function() {
  Debug.log("begin YAHOO.init.translateGreeting");
	var username;
	username = YAHOO.oib.login;
  I18n.update('greeting', 'GREETING', [username]);
};

YAHOO.init.translateSubhead = function() {
  try {
    var total_organized_messages, formatted_date;
    
    total_organized_messages = Try.these(function() {
        return YAHOO.oib.response.total_organized_messages;
      }
    );
  
    formatted_date = Try.these(function() {
      var since_date;
      since_date = YAHOO.oib.response.since_date.s;
      return formatUnixDate(since_date);
    });
  
    if (total_organized_messages && formatted_date) {
      I18n.update('toolbar_subhead', 'TOOLBAR_SUBHEAD', [total_organized_messages, formatted_date]);
    }
  } catch(err) {
    Debug.log("error in YAHOO.init.translateSubhead: " + err);
  }
};


YAHOO.init.translateFooter = function() {
  I18n.update('copyright', 'COPYRIGHT');
  I18n.update('about_link', 'ABOUT');
  I18n.update('support_link', 'SUPPORT');
  I18n.update('contact_link', 'CONTACT');
  I18n.update('privacy_link', 'PRIVACY');
  I18n.update('terms_and_conditions_link', 'TERMS_AND_CONDITIONS');
};

