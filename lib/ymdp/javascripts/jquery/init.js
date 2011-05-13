/* 

INITIALIZER CODE

*/

// Adds behaviors/observers to elements on the page
//
YMDP.Init.addBehaviors = function() {
	// overwrite this function locally
};

// hide the loading screen and show the main body of the summary
YMDP.Init.show = function() {
  Debug.log("YMDP.Init.show");
  try {
    $('#utility').hide();
    $('#error').hide();
  	$('#loading').hide();
    $('#main').show();
  } catch(e) {
    Debug.error("Error in YMDP.Init.show", e);
  }
};


// Local initializer.  When your page starts up, this method will be called after fetching the user's guid and ymail wssid.
//
YMDP.Init.local = function() {
  throw("This hasn't been overwritten.");
	// overwrite this function locally
};

// To be run before any other initializers have run.
//
YMDP.Init.before = function() {
	// overwrite this function locally
};

// Main startup code. Overwrite this function to execute after YMDP.Init.before and before YMDP.Init.after.
//
YMDP.Init.startup = function() {
  Debug.log("init.startup");
	// gets the user
	YMDP.getGuid(function(guid) {
	  try {
  	  Reporter.reportCurrentView(guid);
	  } catch(omg) {
	    Debug.error(omg);
	  }
    YMDP.getUserState(YMDP.Init.local, YMDP.Init.local);
  });
};

YMDP.Init.abTesting = function() {
  // to enable abTesting in your view, overwrite this file locally.
  // 
  // be sure to finish your post-Ajax callback with YMDP.Init.show()
  //
  YMDP.Init.show();
	YMDP.Init.after();
};

// Finishing code. Runs after startup, executes translations and behaviors.  Shows the page and then 
// runs the A/B testing callback, which in turn will execute the last callbacks.
//
YMDP.Init.finish = function() {
  // try {
    Debug.log("init.finish for view " + View.name);
  	YMDP.showTranslations();
  	Debug.log("addBehaviors:");
  	YMDP.Init.addBehaviors();
  	Debug.log("abTesting:");
    YMDP.Init.abTesting();
  	Debug.log("page_loaded = true:");
    View.page_loaded = true;
    Debug.log("finished init.finish for view " + View.name);
  // } catch(omg) {
  //   Debug.error("Error in YMDP.Init.finish", omg);
  //   YMDP.showError({
  //     "method": "YMDP.Init.finish",
  //     "description": "exception caught in YMDP.Init.finish",
  //     "error": omg
  //   });
  // }
};

// Post-initalizer. Very last thing that runs, after content has been shown.
//
YMDP.Init.after = function() {
	// overwrite this function locally
};

// Execute the before, startup and after methods. Do not overwrite. (Change YMDP.Init.startup to create a custom initializer.)
YMDP.init = function() {
  Debug.log("OIB.init for view " + View.name, "<%= @message %>");
  try {
    Logger.init();
    Tags.init();
    YMDP.Init.browser();
    YMDP.Init.resources();
    I18n.addLanguageToBody();
    I18n.translateLoading();
    I18n.translateError();
    YMDP.Init.before();
    YMDP.Init.startup();
  } catch(err_f) {
    YMDP.showError({
      "method": "YMDP.init",
      "description": "exception caught in YMDP.init",
      "error": err_f
    });
    Debug.error("Error in YMDP.init", err_f);
  }
};

YMDP.Init.browser = function() {
  if ($.browser.webkit) {
    $('body').addClass('webkit');
  }
};

YMDP.Init.resources = function() {
  Debug.log("about to call I18n.setResources");

  I18n.availableLanguages = <%= supported_languages.to_json %>;

  I18n.currentLanguage = OpenMailIntl.findBestLanguage(I18n.availableLanguages);
  
  I18n.setResources();

  Debug.log("finished calling I18n.setResources");
};

// Contains the last two callbacks, to show the page contents and run post-show function.  Do not overwrite.
YMDP.Init.showAndFinish = function() {
  Debug.log("YMDP.Init.showAndFinish");
  YMDP.Init.show();
  YMDP.Init.after();
};
