window.Logger =
  on: false
  
  init: ->
    OIB.get "ymdp/state", {}, (response) ->
      Logger.on = response.observe
    , () ->
      Debug.log("Got error")
  
  observe: (message) ->
    if this.on
      this.log(message)
  
  log: (message) ->
    # console.log("LOGGING " + message);
    
    OIB.post "ymdp/logs",
      "_hide_debug": true,
      "log": message
    , ->
