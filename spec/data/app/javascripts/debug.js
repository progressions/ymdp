var Debug;

Debug = {
  on: false,
  console: false,
  alerts: false, 
  logs: false,
  ajaxErrors: false,
  
  consoleOn: function() {
    return (typeof window['console'] !== 'undefined' && this.console);
  },
  
  alertsOn: function() {
    return (Debug.on || Debug.logs);
  },
  
  logsOn: function() {
    return (Debug.on || Debug.logs);
  },
  
  ajaxErrorsOn: function() {
    return (Debug.on || Debug.ajaxErrors);
  },
  
  profile: function(name) {
    if (this.consoleOn()) {
      console.profile(name);
    }
  },
  
  profileEnd: function(name) {
    if (this.consoleOn()) {
      console.profileEnd(name);
    }    
  },
  
  call: function(level, message, obj) {
    try {
      message = this.message(message, obj);

      if (Debug.consoleOn()) {
        console[level](message);
      }
      if (Debug.logsOn()) {
        alert(message);
      }
    } catch(e) {
      if (Debug.consoleOn()) {
        console[level](e);
      } else {
        alert(e);
      }
    }    
  },
  
  log: function(message, obj) {
    this.call("log", message, obj);
  },
  
  error: function(message, obj) {
    this.call("error", message, obj);
  },
  
  info: function(message, obj) {
    this.call("info", message, obj);
  },
  
  warn: function(message, obj) {
    this.call("warn", message, obj);
  },
  
  alert: this.log,
  
  ajaxError: function(message, path, params, response) {
    var m;
    m = message + " path: " + path + "?" + Object.toQueryString(params);
    m = m + ", response: " + Object.toJSON(response);
    
    try {
      $('error_details').update(m);
    } catch(err) {
      YAHOO.logger.error(err);
    }
    
    this.error(m);
    
    if (Debug.ajaxErrorsOn()) {
      alert(m);
    }
    if (Debug.logsOn()) {
      YAHOO.logger.error(m);
    }
  },
  
  message: function(message, obj) {
    try {
      message = this.timestamp() + " " + this.generalInfo() + " " + message;    
      if (obj) {
        message = message + ", " + Object.toJSON(obj);
      }
    } catch(e) {
      // alert(e);
    }
    return message;
  },
  
  timestamp: function() {
    var time, year, month, date, hour, minute, second, timestamp, checktime;
    
    checktime = function checkTime(i) {
      if (i<10) {
        i="0" + i;
      }
      return i;
    };
    
    time = new Date();
    // year = time.getFullYear();
    // month = time.getMonth() + 1;
    // date = time.getDate();
    hour = checktime(time.getHours());
    minute = checktime(time.getMinutes());
    second = checktime(time.getSeconds());
    
    // timestamp = month + "/" + date + "/" + year + " " + 
    
    timestamp = hour + ":" + minute + ":" + second;
    
    return timestamp;
  },
  
  generalInfo: function() {
    return "[<%= @domain %>/<%= @server %>] [<%= @version %> <%= @sprint_name %>]";
  }
};

Debug.console = true;