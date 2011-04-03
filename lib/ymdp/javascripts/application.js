/*
	APPLICATION

  // DO NOT USE the @view instance variable in any files in /app/javascripts/base.
  // The way they are cached makes it not safe to do so.

*/

var OIB;

/* 
	GLOBAL CONSTANTS 
*/

var View = {
  application: "<%= @application_name %>",
  domain: "<%= @domain %>",
  
  authorized: function(user) {
    return (user[View.application + "_user"]);
  }
};

YAHOO.namespace("oib");
YAHOO.namespace("constants");
YAHOO.namespace("images");
YAHOO.namespace("init");

YAHOO.oib.page_loaded = false;

function unixTimeToDate(unixtime) {
  return new Date(unixtime * 1000);
}

function formatUnixDate(unixtime) {
  var date;
  date = unixTimeToDate(unixtime);
  return date.toString("MMMM d, yyyy");
}

// Shows the error view.
//
// YAHOO.oib.showError({
//   heading: "optional heading text can overwrite the error view's heading",
//   message: "optional message can overwrite the view's first paragraph",
//   retry: "hide"
// });
// 
// Set the "retry" option to "hide" to hide the Retry button.
//

YAHOO.oib.showError = function(options) {
  var params;
  
  Debug.log("YAHOO.oib.showError", options);
  
  options = options || {};
  
  if (options["heading"]) {
    $("error_1").update(options["heading"]);
  }
  if (options["message"]) {
    $("error_2").update(options["message"]);
  }
  if (options["retry"] && options["retry"] === "hide") {
    $("retry_button_container").hide();
  }
  
  params = {};
  params["description"] = options["description"];
  params["method_name"] = options["method"];
  params["error"] = Object.toJSON(options["error"]);
  params["page"] = View.name;
  
  Reporter.error(YAHOO.oib.guid, params);
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

YAHOO.init.upgradeCheck = function(success_callback, failure_callback) {
  // test for Minty
  //
  openmail.Application.getParameters(function(response) {
    if (response.version === "2") {

      // Minty-only code goes here

      try {
        Debug.log("Minty found");
        
        success_callback();
      } catch(wtf) {
        Debug.error(wtf);
      }
    } else {
      // non-Minty
      
      if (failure_callback) {
        failure_callback();
      } else {
        YAHOO.init.upgrade();
      }
    }
  });  
};

YAHOO.init.upgrade = function() {
  YAHOO.oib.showTranslations();
	
  YAHOO.oib.page_loaded = true;
  
  $('loading').hide();
  $('error').hide();
  $('upgrade').show();
};

YAHOO.oib.setTimeoutInSeconds = function(callback_function, interval) {
	setTimeout(callback_function, interval * 1000);
};

YAHOO.oib.showTranslations = function() {
  Debug.log("begin YAHOO.oib.showTranslations");
	Try.these(I18n.findAndTranslateAll);

	// define I18n.localTranslations in the view template
	Try.these(I18n.localTranslations);
	
  Debug.log("end YAHOO.oib.showTranslations");
};

