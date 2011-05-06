var Logger;

Logger = {
  on: false,
  
  init: function() {
    OIB.get("ymdp/state", {}, function(response) {
      Logger.on = response.observe;
    });
  },
  
  observe: function(message) {
    if (this.on) {
      this.log(message);
    }
  },
  
  log: function(message) {
    // console.log("LOGGING " + message);
    OIB.post("ymdp/logs", {
      "_hide_debug": true,
      "log": message
    }, function() {
      
    });
  }
};