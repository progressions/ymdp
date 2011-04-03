/*
  LAUNCHING
 
  global to every view.  launches new views and closes the current one.

  // DO NOT USE the @view instance variable in any files in /app/javascripts/base.
  // The way they are cached makes it not safe to do so.

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


YAHOO.launcher.launchTab = function(view, title) {
	YAHOO.launcher.launch(view, title, "tab");
};

// User must be signed in for this page, we'll 
// sign them in if they don't have an OIB cookie
//
YAHOO.launcher.launchActiveTab = function(view, title) {
  YAHOO.launcher.launchTab(view, title);
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