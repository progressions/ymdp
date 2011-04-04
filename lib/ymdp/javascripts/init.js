/* 

INITIALIZER CODE

*/

// Adds behaviors/observers to elements on the page
//
YAHOO.init.addBehaviors = function() {
	// overwrite this function locally
};

// hide the loading screen and show the main body of the summary
YAHOO.init.show = function() {
  Debug.log("YAHOO.init.show");
  try {
    $('utility').hide();
    $('error').hide();
  	$('loading').hide();
    $('main').show();
  } catch(e) {
    Debug.error("Error in YAHOO.init.show", e);
  }
};


// Local initializer.  When your page starts up, this method will be called after fetching the user's guid and ymail wssid.
//
YAHOO.init.local = function() {
  throw("This hasn't been overwritten.");
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
	  try {
  	  Reporter.reportCurrentView(guid);
	  } catch(omg) {
	    Debug.error(omg);
	  }
    YAHOO.oib.getUserState(YAHOO.init.local, YAHOO.init.local);
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
  try {
    Debug.log("init.finish for view " + View.name);
  	Try.these(YAHOO.oib.showTranslations);
  	Try.these(YAHOO.init.addBehaviors);
    Try.these(YAHOO.init.abTesting);
    YAHOO.oib.page_loaded = true;
    Debug.log("finished init.finish for view " + View.name);
  } catch(omg) {
    Debug.error("Error in YAHOO.init.finish", omg);
    YAHOO.oib.showError({
      "method": "YAHOO.init.finish",
      "description": "exception caught in YAHOO.init.finish",
      "error": omg
    });
  }
};

// Post-initalizer. Very last thing that runs, after content has been shown.
//
YAHOO.init.after = function() {
	// overwrite this function locally
};

// Execute the before, startup and after methods. Do not overwrite. (Change YAHOO.init.startup to create a custom initializer.)
YAHOO.oib.init = function() {
  Debug.log("OIB.init for view " + View.name, "<%= @message %>");
  try {
    YAHOO.init.browser();
    YAHOO.init.resources();
    I18n.addLanguageToBody();
    I18n.translateLoading();
    I18n.translateError();
    YAHOO.init.before();
    YAHOO.init.startup();
  } catch(err_f) {
    YAHOO.oib.showError({
      "method": "YAHOO.oib.init",
      "description": "exception caught in YAHOO.oib.init",
      "error": err_f
    });
    Debug.error("Error in YAHOO.oib.init", err_f);
  }
};

YAHOO.init.browser = function() {
  if (Prototype.Browser.WebKit) {
    $$('body').first().addClassName('webkit');
  }
};

YAHOO.init.resources = function() {
  Debug.log("about to call I18n.setResources");

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
