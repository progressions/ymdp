window.User = 

# gets user's state info from /ymdp/state
# including the user's OIB login
#
  getState: (success_function, error_function) ->
    Debug.log("User.getState")
    
    success = (response) ->
      Debug.log("User.getState callback", response)
      User.setVariables(response)

      if success_function
        Debug.log("User.getState: About to success function")
        success_function(response)
    error = ->
      Debug.log("Failed to get user's state")
      error_function() if error_function
      
    OIB.get "ymdp/state", {}, success, error
  

  setVariables: (response) ->
    YMDP.response = response
    try
      YMDP.since_date = formatUnixDate(YMDP.response.since_date.s)
    catch omg
      YMDP.since_date = 1294869484
  
    YMDP.login = response.login
    YMDP.state = response.state

  ###
      User.verify

      global to all views.  calls the 'verify' action on ymdp controller and executes
      a function with the result.
    
      Sends the server the user's guid and 'ymail_wssid', which signs the user in if the
      values match what we have in the database.
  ###
  
  verify: (success_function, error_function) ->
    Debug.log("User.verify")
  
    params =
      ymail_guid: YMDP.guid,
      ymail_wssid: YMDP.ymail_wssid
    success = (response) ->
      YMDP.user = response
      Debug.log("User.verify YMDP.user", YMDP.user)
      if success_function
        Debug.log("User.verify: About to success function")
        success_function(YMDP.user)
  
    OIB.get "ymdp/verify", params, success, error_function


  ###
      AUTHENTICATION
  ###

  # Gets the ymail_wssid which is stored in the database on the remote server
  # for the current user.
  #
  confirm: ->
    Debug.log("User.confirm")
    OIB.get "ymdp/signin",
      "ymail_guid": YMDP.guid
    , User.confirmation

  # Handle response from User.confirm
  #
  confirmation: (response) ->
    Debug.log("inside ymdp/signin callback", response)
  
    if response.ymail_wssid
      Debug.log("YMDP.response wasn't false", response.ymail_wssid)
      User.storeYmailWssid(response.ymail_wssid)

      # now that we've got their ymail_wssid, we can sign them in:
      User.verify(Launcher.launchMain)
    else
      # signin didn't work properly, display an error
      Debug.log("YMDP.response was false")
      YMDP.showError
        "method": "User.confirm",
        "description": "no ymail_wssid"

  # Store ymail_wssid in permanent store.
  #
  storeYmailWssid: (ymail_wssid) ->
    raw_wssid = ymail_wssid || ""
    sliced_wssid = raw_wssid.slice(0, 255)
  
    data =
      "ymail_wssid": sliced_wssid
  
    Debug.log("About to call Data.store", data)
  
    Data.store(data)
    YMDP.ymail_wssid = ymail_wssid 

  # gets both guid and ymail_wssid and stores them then runs the callback_function
  #
  # YMDP.ymail_wssid
  # YMDP.guid
  #
  getGuidAndYmailWssid: (callback_function) ->
    Debug.log("User.getGuidAndYmailWssid")
    User.getGuid (guid) ->
      User.getYmailWssid (ymail_wssid) ->
        callback_function(guid, ymail_wssid)

  # gets the ymail_wssid from the permanent store and executes the callback function
  # if there is a ymail_wssid, and the error callback if it's undefined
  #
  # YMDP.ymail_wssid
  #
  getYmailWssid: (success_function, error_function) ->
    Debug.log("User.getYmailWssid")
  
    # this function will show the error page if the ymail_wssid has not been set
    #
    show_error = ->
      if !YMDP.ymail_wssid
        Debug.log("No YMDP.ymail_wssid")
      
        YMDP.showError
          "retry": "hide"
  
    # retrieve the user's ymail_wssid and store it in YMDP.ymail_wssid
    #
    Data.fetch ["ymail_wssid"], (response) ->
      Debug.log("Inside Data.fetch callback")
      YMDP.ymail_wssid = response.data.ymail_wssid
    
      Debug.log("YMDP.ymail_wssid is defined", YMDP.ymail_wssid)
    
      try
        success_function(YMDP.ymail_wssid)
      catch wtf
        Debug.log wtf

  # gets the guid from the Yahoo! environment and executes the success callback
  # if there is a guid, and the error callback if it's undefined
  #
  # YMDP.guid
  #
  getGuid: (success_function, error_function) ->
    Debug.log("User.getGuid")
  
    openmail.Application.getParameters (response) ->
      Debug.log("getParameters callback")
      YMDP.guid = response.user.guid
    
      Debug.log("User.getGuid getParameters response", response)
    
      params = {}
      if response.data
        params = response.data.launchParams
    
      Params.init(params)
    
      if YMDP.guid != undefined
        success_function(YMDP.guid)
      else
        error_function()

  deactivate: ->
    User.getGuidAndYmailWssid (guid, ymail_wssid) ->
      Data.clear()

      params =
        "ymail_guid": guid,
        "ymail_wssid": ymail_wssid

      OIB.post "/ymdp/deactivate", params, 
      (response) ->
        if View.name != "deactivate"
          Launcher.launchGoodbye()
