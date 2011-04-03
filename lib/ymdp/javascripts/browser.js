var Browser;

Browser = {
  version: function(v) {
    var version, app_version;
    app_version = navigator.appVersion;
    Debug.log("Browser app_version: ", app_version);
  
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

