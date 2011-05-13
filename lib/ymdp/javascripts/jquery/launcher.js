/*
  LAUNCHING
 
  global to every view.  launches new views and closes the current one.

  // DO NOT USE the @view instance variable in any files in /app/javascripts/base.
  // The way they are cached makes it not safe to do so.

*/

/* set asset version */

var Launcher;

Launcher = {};

Launcher.launch = function(view, title, type) {
  openmail.Application.getParameters(function(response) {
  	title = I18n.t("APPLICATION_NAME");
		// don't try to relaunch current tab
		if (response.data === null || response.data.view !== view) {
			openmail.Application.openView(
			{
				id: view, 
				view: view, 
				target: type, 
				title: title,
				parameters: {
				  launchParams: Params.parameters,
				  view: view
				}
			});
			openmail.Application.closeView(null);
		}
	});
};


Launcher.launchView = function(launch_view) {
  var user;
  
  user = YMDP.user || {"state": "active"};
  
  switch(user.state) {
    case "scanning":
      // formerly known as 'inspect'
      Launcher.launchScanning();
      break;
    case "summary":
      Launcher.launchSummary();
      break;
	    case "authorized":
      // authorized but not yet 'signed in'
       YMDP.signInUser();
       break;
     case "new_active":
       // no messages processed yet
     case "processing":
       // activated but we have synced fewer than 80% of their messages
    case "active":
      // active, launch the view this method was intended for
      launch_view();
      break;
    default:
      // other
      Launcher.launchAuthorize();
  }
};


Launcher.launchTab = function(view, title) {
	Launcher.launch(view, title, "tab");
};

// User must be signed in for this page, we'll 
// sign them in if they don't have an OIB cookie
//
Launcher.launchActiveTab = function(view, title) {
  Launcher.launchTab(view, title);
};


Launcher.launchAuthorize = function() {
  Launcher.launchTab("authorize", "Authorize");
};

Launcher.launchDeactivate = function() {
  Launcher.launchHidden("deactivate", "Deactivate");
};

Launcher.launchHidden = function(view, title) {
	Launcher.launch(view, title, "hidden");
};

Launcher.l = function(view) {
	view = "launch" + view.capitalize();
	Launcher[view]();
};

Launcher.launchGoodbye = function() {
  Launcher.launchTab("goodbye", "Goodbye");
};

Launcher.relaunchAuthorize = Launcher.launchAuthorize;

Launcher.launchMaintenance = function() {
  Launcher.launchTab("maintenance", "Maintenance");
};

Launcher.launchReauthorize = function() {
  Launcher.launchTab("reauthorize", "Reauthorize");
};

Launcher.launchView = function(launch_view) {
  // get Yahoo! user's guid and ymail_wssid
  YMDP.getGuidAndYmailWssid(function(guid, ymail_wssid) {
	 				
    // call /ymdp/verify and return data about the user
    YMDP.verifyUser(function(user) {

      YMDP.login = user.login;
	  
  	  switch(user.state) {
  	    case "scanning":
  	      // formerly known as 'inspect'
          Launcher.launchScanning();
          break;
  	    case "summary":
          Launcher.launchSummary();
          break;
   	    case "authorized":
  	      // authorized but not yet 'signed in'
           YMDP.signInUser();
           break;
         case "new_active":
           // no messages processed yet
         case "processing":
           // activated but we have synced fewer than 80% of their messages
  	    case "active":
  	      // active, launch the view this method was intended for
  	      launch_view();
  	      break;
  	    default:
  	      // other
  	      Launcher.launchAuthorize();
  	  }
    });
  });
};

Launcher.launchMain = function() {
  Launcher.launchView(Launcher.launchFolders);
};
