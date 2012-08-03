###
  AUTHORIZE USER
          
  Authorize and sign in the user.
###

window.Authorize =
  init: (guid, default_state, params) ->
    Debug.log("Authorize.init")
    params = params || {}
    if Params.get("invitation")
      params["invitation"] = Params.get("invitation")
      
    params["application"] = View.application
    Authorize.url = YMDP.Constants.controller_url + "/authorize/" + guid
    Authorize.locale = params.locale
    Authorize.default_state = default_state
    
    Authorize.params = params
    Debug.log("end of Authorize.init")
  
  assignUrl: (url) ->
    Debug.log("assignUrl", url)

    url = url || Authorize.url
    url = url + "?" + $.param(Authorize.params)
    
    $(".get_started").attr("href", url).attr("target", "_blank")
    $("#get_started_1").attr("href", url).attr("target", "_blank")
    $("#get_started_2").attr("href", url).attr("target", "_blank")

    Debug.log("just assigned url")
  
  authorize: ->
    Debug.log("Authorize.authorize")
    User.getState (response) ->
      if Authorize.authorized(response)
        Authorize.confirm()
      else
        Debug.log("About to startScanning")
        Authorize.startScanning()
  
  startScanning: ->
    Debug.log("Authorize.startScanning", Authorize.scanner)
    if !Authorize.scanner
      Debug.log("Authorize.scanner doesnt exist", Authorize.scanner)
      Authorize.scanner = window.setInterval(Authorize.scan, 5000)
    else
      Debug.log("Authorize.scanner does exist", Authorize.scanner)
  
  authorized: (response) ->
    Debug.log("Authorize.authorized", response)
    return !!(response.state != Authorize.default_state && View.authorized(response))
  
  confirm: User.confirm
  
  scan: ->
    Debug.log("Authorize.scan")
    if Authorize.stop_scanning
      Debug.log("Authorize.stop_scanning is true", Authorize.stop_scanning)
      window.clearInterval(Authorize.scanner)
    else
      Debug.log("Authorize.stop_scanning is not true", Authorize.stop_scanning)
    
    Debug.log("About to getUserState")
    
    User.getState Authorize.scanResponse, (response) ->
      # error function
      Debug.error("Error in Authorize.scan's getUserState", response)
    
      if Authorize.scanner
        window.clearInterval(Authorize.scanner)
  
  scanResponse: (response) ->
    Debug.log("inside Authorize.scan's getUserState callback", response)
    if response.state != Authorize.default_state
      Debug.log("not default state, about to Authorize.confirm()")
      
      Authorize.confirm()
      if Authorize.scanner
        window.clearInterval(Authorize.scanner)
        
      Authorize.scanner = undefined
      Debug.log("just set Authorize.scanner to undefined")
  
  addBehaviors: ->
    Debug.log("Authorize.addBehaviors")
    $("#get_started_1").click(Authorize.authorize)
    $("#get_started_2").click(Authorize.authorize)
    $(".get_started").click(Authorize.authorize)
  
  verify: ->
    # call /ymdp/verify and return data about the user
    User.verify (user) ->
      Debug.log("inside User.verify callback", user)
      
      YMDP.user = user
      YMDP.login = user.login
      YMDP.Init.switchOnState(user)
    , (response) ->
      # call to ymdp/verify was not a 200 response, show error
      YMDP.showError
        "method_name": "User.verify",
        "description": "error response"

