/*
  LAUNCHING
 
  global to every view.  launches new views and closes the current one.
*/

/* set asset version */

var LAUNCHER, Launcher;

LAUNCHER = {
  VERSION: "<%= @hash %>",
  MESSAGE: "<%= @message %>",
  DEPLOYED: <%= Time.now.to_i %>,
  DEPLOYED_STRING: "<%= Time.now.to_s %>"
};

YAHOO.namespace("launcher");


YAHOO.launcher.launch = function(view, title, type) {
  openmail.Application.getParameters(function(response) {
  	title = I18n.t("ORGANIZER");
		// don't try to relaunch current tab
		if (response.data === null || response.data.view !== view) {
			openmail.Application.openView(
			{
				id: view, 
				view: view, 
				target: type, 
				title: title,
				parameters: {
					view: view
				}
			});
			openmail.Application.closeView(null);
		}
	});
};


YAHOO.launcher.launchTab = function(view, title) {
  Try.these(function () {
  	var translated_title;
  	translated_title = I18n.t(title);
  	
	  if (translated_title) {
	  	title = translated_title;
	  	title[0] = title[0].capitalize();
	  }
   
  });
	YAHOO.launcher.launch(view, title, "tab");
};

// User must be signed in for this page, we'll 
// sign them in if they don't have an OIB cookie
//
YAHOO.launcher.launchActiveTab = function(view, title) {
 YAHOO.launcher.launchView(function() {
   YAHOO.launcher.launchTab(view, title);
  });
};

	
YAHOO.launcher.launchView = function(launch_view) {
// get Yahoo! user's guid and ymail_wssid
 YAHOO.oib.getGuidAndYmailWssid(function(guid, ymail_wssid) {
	 				
  // call /ymdp/verify and return data about the user
     YAHOO.oib.verifyUser(function(user) {
       
       // YAHOO.logger.info("Called switcher in state '" + YAHOO.constants.states[user.state] + "'");
  
       YAHOO.oib.login = user.login;
       var state;
       state = parseInt(user.state, 10);
	  
	  switch(YAHOO.constants.states[user.state]) {
	    case "inspect":
	      // inspect
	      
        // launch_view();
        YAHOO.launcher.launchInspect();
        break;
 	    case "authorized":
	      // authorized but not yet 'signed in'
         YAHOO.oib.signInUser();
         break;
       case "new_active":
         // no messages processed yet
       case "processing":
         // activated but we have synced fewer than 80% of their messages
	    case "active":
	      // active, launch the view this method was intended for
	      launch_view();
	      break;
	    // case "inactive":
	      // inactive
	    default:
	      // other
	      YAHOO.launcher.launchAuthorize();
	  }
  });
});
};



YAHOO.launcher.launchIdentity = function() {
  YAHOO.launcher.launchActiveTab("identity", "My Account");
};

YAHOO.launcher.launchSettings = function() {
  YAHOO.launcher.launchActiveTab("settings", "Settings");
  // YAHOO.launcher.launchActiveTab("goodbye", "Settings");
};

YAHOO.launcher.launchInspect = function() {
  YAHOO.launcher.launchTab("inspect", "Inspect");
};

YAHOO.launcher.launchAuthorize = function() {
  YAHOO.launcher.launchTab("authorize", "Authorize");
};

YAHOO.launcher.launchDeactivate = function() {
  YAHOO.launcher.launchHidden("deactivate", "Deactivate");
};

YAHOO.launcher.launchHidden = function(view, title) {
	YAHOO.launcher.launch(view, title, "hidden");
};

YAHOO.launcher.l = function(view) {
	view = "launch" + view.capitalize();
	YAHOO.launcher[view]();
};

YAHOO.launcher.launchStatistics = function() {
  YAHOO.launcher.launchTab("statistics", "Statistics");
};

YAHOO.launcher.launchGoodbye = function() {
  YAHOO.launcher.launchTab("goodbye", "Goodbye");
};

YAHOO.launcher.relaunchAuthorize = YAHOO.launcher.launchAuthorize;

YAHOO.launcher.launchMaintenance = function() {
  YAHOO.launcher.launchTab("maintenance", "Maintenance");
};

YAHOO.launcher.launchReauthorize = function() {
  YAHOO.launcher.launchTab("reauthorize", "Reauthorize");
};

Launcher = YAHOO.launcher;

