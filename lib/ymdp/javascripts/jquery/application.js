/*
	APPLICATION

  // DO NOT USE the @view instance variable in any files in /app/javascripts/base.
  // The way they are cached makes it not safe to do so.

*/

var OIB, YMDP;

/* 
	GLOBAL CONSTANTS 
*/

var View = {
  application: "<%= @application_name %>",
  domain: "<%= @domain %>",
  page_loaded: false,
  
  authorized: function(user) {
    return (user[View.application + "_user"]);
  }
};

var YMDP = {
  Constants: {},
  Init: {}
};

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
// YMDP.showError({
//   heading: "optional heading text can overwrite the error view's heading",
//   message: "optional message can overwrite the view's first paragraph",
//   retry: "hide"
// });
// 
// Set the "retry" option to "hide" to hide the Retry button.
//

YMDP.showError = function(options) {
  var params;
  
  options = options || {};
  
  if (options["heading"]) {
    $("#error_1").html(options["heading"]);
  }
  if (options["message"]) {
    $("#error_2").html(options["message"]);
  }
  if (options["retry"] && options["retry"] === "hide") {
    $("#retry_button_container").hide();
  }
  
  params = {};
  params["description"] = options["description"];
  params["method_name"] = options["method"];
  params["error"] = YAHOO.lang.JSON.stringify(options["error"]);
  params["page"] = View.name;
  
  Reporter.error(YMDP.guid, params);
  $('#main').hide();
  $('#utility').show();
	$('#loading').hide();
	$('#error').show();
};

YMDP.showLoading = function() {
  $('#main').hide();
  $('#utility').show();
  $('#error').hide();
  $('#loading').show();
};

YMDP.Init.upgradeCheck = function(success_callback, failure_callback) {
  // test for Minty
  //
  openmail.Application.getParameters(function(response) {
    if (response.version === "2") {

      // Minty-only code goes here

      Debug.log("Minty found");
      
      success_callback();
    } else {
      // non-Minty
      
      if (failure_callback) {
        failure_callback();
      } else {
        YMDP.Init.upgrade();
      }
    }
  });  
};

YMDP.Init.upgrade = function() {
  YMDP.showTranslations();
	
  View.page_loaded = true;
  
  $('#loading').hide();
  $('#error').hide();
  $('#upgrade').show();
};

YMDP.setTimeoutInSeconds = function(callback_function, interval) {
	setTimeout(callback_function, interval * 1000);
};

YMDP.showTranslations = function() {
  Debug.log("begin YMDP.showTranslations");
	I18n.findAndTranslateAll();

	// define I18n.localTranslations in the view template
	I18n.localTranslations();
	
  Debug.log("end YMDP.showTranslations");
};

String.prototype.capitalize = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
}