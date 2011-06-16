
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
    
    $(args).each(function(i, arg) {
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
      return(YAHOO.lang.JSON.stringify(obj));
    }
  },
    
  checktime: function(i) {
    if (i<10) {
      i="0" + i;
    }
    return i;
  },
  
  timestamp: function() {
    var time, hour, minute, second, timestamp, checktime;
    
    time = new Date();
    hour = this.checktime(time.getHours());
    minute = this.checktime(time.getMinutes());
    second = this.checktime(time.getSeconds());
    
    // timestamp = month + "/" + date + "/" + year + " " + 
    
    timestamp = hour + ":" + minute + ":" + second;
    
    return timestamp;
  },
  
  generalInfo: function() {
    return "[<%= @version %> <%= @sprint_name %>]";
  }
};