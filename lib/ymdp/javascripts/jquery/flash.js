
  // DO NOT USE the @view instance variable in any files in /app/javascripts/base.
  // The way they are cached makes it not safe to do so.

var Flash;
 
/* FLASH MESSAGE HANDLERS */

Flash = {};

Flash.timeout = 8;
Flash.duration = 0.25;

Flash.write = function(type, message) {
	type = type || "notice";
  if (message) {
    $('#flash_message').html(message);
    Flash.setFlashClass('#flash', type);
    $('#flash').show();
    YMDP.setTimeoutInSeconds(Flash.close, Flash.timeout);
	}
};

Flash.close = function() {
  $('#flash').hide();
};

Flash.setFlashClass = function(flash_id, type) {
  if (type === "error") {
    $(flash_id).removeClass('notice');
  }
  if (type === "notice") {
    $(flash_id).removeClass('error');
  }
  $(flash_id).addClass(type);
};


Flash.error = function(message) {
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

/* ----------------------- */
