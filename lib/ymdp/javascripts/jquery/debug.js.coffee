
  # DO NOT USE the @view instance variable in any files in /app/javascripts/base.
  # The way they are cached makes it not safe to do so.

window.Debug = 
  on: false
  console: true
  logs: false
  
  consoleOn: ->
    typeof window['console'] != 'undefined' && this.console
  
  call: ->
    args = [].slice.call(arguments,0)
    level = args.shift()
    
    message = this.message.apply(Debug, args)

    if this.consoleOn()
      console[level](message)
      
    Logger.observe(message)
  
  log: ->
    args = [].slice.call(arguments,0)
    args.unshift("log")
    this.call.apply(this, args)
  
  error: ->
    args = [].slice.call(arguments,0)
    args.unshift("error")
    this.call.apply(this, args)
  
  message: ->
    args = [].slice.call(arguments,0)
    parts = []
    
    parts.push(this.timestamp())
    parts.push(this.generalInfo())
    
    $(args).each (i, arg) ->
      parts.push(Debug.object(arg))
    
    message = parts.join(" ")
    
    message
  
  object: (obj) ->
    if (typeof obj == "string")
      obj
    else if (obj == undefined)
      "undefined"
    else if (obj == null)
      "null"
    else if obj.message
      obj.message
    else if (obj.inspect)
      obj.inspect()
    else
      JSON.stringify(obj)
    
  checktime: (i) ->
    if i<10
      i="0" + i
      
    i
  
  timestamp: ->
    time = new Date()
    hour = this.checktime(time.getHours())
    minute = this.checktime(time.getMinutes())
    second = this.checktime(time.getSeconds())
    
    hour + ":" + minute + ":" + second
  
  generalInfo: ->
    "[<%= @version %> <%= @sprint_name %>]"
    