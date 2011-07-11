window.Data = 
  # values cannot be longer than 255 chars
  #
  store: (data, success_function, error_function) ->
    Debug.log("Data.store", data)
    
    keys = 
      "keys": data
      
    openmail.Application.setData keys, (response) ->
      Debug.log("openmail.Application.setData response", response)

      if typeof(response.error) != 'undefined' && response.error != YAHOO.openmail.ERR_NONE
        # storage error detected
        Debug.error("Error saving data", response)
        
        if typeof(error_function) != 'undefined'
          error_function(response)
      else
        if typeof(success_function) != 'undefined'
          success_function(response)
  
  # keys must be an array
  #
  fetch: (keys, success_function, error_function) ->
    Debug.log("Data.fetch", keys)
    
    keys = 
      "keys": keys
    
    openmail.Application.getData keys, (response) ->
      Debug.log("Inside openmail.Application.getData callback", response)
    
      if typeof(response.error) != 'undefined' && (response.error != YAHOO.openmail.ERR_NONE)
        Debug.error("Error retrieving data", response)
        if typeof(error_function) != 'undefined'
          error_function(response)
      else
        Debug.log("success in openmail.Application.getData", response)
        if typeof(success_function) != 'undefined'
          success_function(response)
  
  clear: -> 
    Data.store
      "ymail_wssid": null
    , (response) ->
      YMDP.guid = null
      YMDP.ymail_wssid = null
      
      