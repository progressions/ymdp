
  // DO NOT USE the @view instance variable in any files in /app/javascripts/base.
  // The way they are cached makes it not safe to do so.

var Debug;

Debug = {
  on: false,
  console: true,
  logs: false,
  
  consoleOn: function() {
    return (typeof window['console'] !== 'undefined' && this.console);
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
  
  call: function() {
    var level, message;
    var args = [].slice.call(arguments,0);
    level = args.shift();
    
    message = this.message.apply(Debug, args);

    if (this.consoleOn()) {
      console[level](message);
    }
    Logger.observe(message);
  },
  
  log: function() {
    var args = [].slice.call(arguments,0);
    args.unshift("log");
    this.call.apply(this, args);
  },
  
  error: function() {
    var args = [].slice.call(arguments,0);
    args.unshift("error");
    this.call.apply(this, args);
  },
  
  message: function() {
    var parts, message;
    parts = [];
    
    parts.push(this.timestamp());
    parts.push(this.generalInfo());
    
    var args = [].slice.call(arguments,0);
    
    args.each(function(arg) {
      parts.push(Debug.object(arg));
    });
    
    message = parts.join(" ");
    
    return message;
  },
  
  object: function(obj) {
    if (typeof obj === "string") {
      return obj;
    } else if (obj === undefined) {
      return "undefined";
    } else if (obj === null) {
      return "null";
    } else if (obj.inspect) {
      return(obj.inspect());
    } else {
      return(Object.toJSON(obj));
    }
  },
    
  checktime: function(i) {
    if (i<10) {
      i="0" + i;
    }
    return i;
  },
  
  timestamp: function() {
    var months, day, year, time, hour, minute, second, timestamp, checktime;
    
    time = new Date();
    month = this.checktime(time.getMonth());
    date = this.checktime(time.getDate());
    year = this.checktime(time.getFullYear());
    hour = this.checktime(time.getHours());
    minute = this.checktime(time.getMinutes());
    second = this.checktime(time.getSeconds());
    
    timestamp = month + "/" + date + "/" + year + " " + hour + ":" + minute + ":" + second;
    
    return timestamp;
  },
  
  generalInfo: function() {
    return "[<%= @domain %>/<%= @server %>] [<%= @version %> <%= @sprint_name %>]";
  }
};
