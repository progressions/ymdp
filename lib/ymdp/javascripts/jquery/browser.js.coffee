window.Browser = 
  version: (v) ->
    app_version = navigator.appVersion
    Debug.log("Browser app_version: ", app_version)
  
    if app_version.match("MSIE 6.0")
      version = 6.0
  
    if v
      version == v
    else
      version

  ie: ->
    navigator.appName.match("Internet Explorer")

  ie6: ->
    Browser.ie() && Browser.version(6.0)

  ie7: ->
    Browser.ie() && Browser.version(7.0)

  ie8: ->
    Browser.ie() && Browser.version(8.0)

