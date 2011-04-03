
  // DO NOT USE the @view instance variable in any files in /app/javascripts/base.
  // The way they are cached makes it not safe to do so.

var FLASH, Flash;

/* set asset version */

FLASH = {
  VERSION: "<%= @hash %>",
  MESSAGE: "<%= @message %>",
  DEPLOYED: <%= Time.now.to_i %>,
  DEPLOYED_STRING: "<%= Time.now.to_s %>"
};

   
/* FLASH MESSAGE HANDLERS */

YAHOO.namespace("flash");

Flash = {};

Flash.timeout = 8;
Flash.duration = 0.25;

Flash.write = function(type, message) {
	type = type || "notice";
  if (message) {
    $('flash_message').update(message);
    Flash.setFlashClass('flash', type);

    // blindDown if the flash is currently hidden
    if ($('flash').getStyle("display") === "none") {
      $('flash').blindDown({queue: "end", duration: Flash.duration});
    }
    YAHOO.oib.setTimeoutInSeconds(Flash.close, Flash.timeout);
	}
};

Flash.close = function() {
  Try.these(function() {
    $('flash').blindUp({queue: "end", duration: Flash.duration});
  });
};

Flash.setFlashClass = function(flash_id, type) {
  if (type === "error") {
    Try.these(function() {
      $(flash_id).removeClassName('notice');
    });
  }
  if (type === "notice") {
    Try.these(function() {
      $(flash_id).removeClassName('error');
    });
  }
  Try.these(function() {
    $(flash_id).addClassName(type);
  });
};


Flash.error = function(message) {
  // YAHOO.logger.error(message);
  Flash.write("error", message, true);
};

Flash.notice = function(message) {
	Flash.write("notice", message, true);
};

Flash.success = Flash.notice;

Flash.t = {};
Flash.t.notice = function(key, args) {
  var m;
  
  m = I18n.t(key, args);
  Flash.notice(m);
};
Flash.t.success = Flash.t.notice;

Flash.t.error = function(key, args) {
  var m;
  
  m = I18n.t(key, args);
  Flash.error(m);
};


Flash.settingsChanged = function() {
  Flash.t.success("SETTINGS_CHANGED");
};
Flash.problemSubmitting = function() {
  Flash.t.error("PROBLEM_SUBMITTING");
};

YAHOO.flash = Flash;

/* ----------------------- */
