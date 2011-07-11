###
	  CALL OIB

	  global to every view.  sends Ajax call to OtherInbox.
###

	# send an Ajax call to OtherInbox.
	# takes as parameters:
	# - the path to call
	# - any additional query string params
	# - a callback function to run when the Ajax call is a success
	# - an optional error function
	# - a base URL to use, if you don't want this call going to YMDP.Constants.base_url
	# TODO refactor this function to take a second params hash where we could stick success_function, error_function, and base_url

window.OIB = 
	get: (oib_path, params, success_function, error_function, base_url) ->
		params.method = "GET"
		OIB.call(oib_path, params, success_function, error_function, base_url)

	post: (oib_path, params, success_function, error_function, base_url) ->
		params.method = "POST"
		OIB.call(oib_path, params, success_function, error_function, base_url)
	
	call: (oib_path, params, success_function, error_function, base_url) ->
	  success = (response) ->
      response = JSON.parse(response.data)
      if (response.error)
        if (error_function)
          error_function(response)
        else
          YMDP.showError
            "method": "OIB.call"
            "description": "error callback"
      else
        if (success_function)
          success_function(response) 
        else
          YMDP.showError
              "method": "OIB.call"
              "description": "success callback error"
              
	  OIB.request(oib_path, params, success, error_function, base_url)
	
	ajax_response: false
	
	ajax: (url, method, params, success_function, error_function) ->
	  params = params || {}
	  params["application"] = View.application
	  
	  debug = !params["_hide_debug"]
	  
	  if (debug)
      Debug.log "OIB.ajax: About to call openmail.Application.callWebService: ", 
        "method": method,
        "url": url + "?" + $.param(params)
    
    openmail.Application.callWebService
    	url: url,
    	method: method,
    	parameters: params
    , (response) ->
      # response from Ajax call was a 200 response
      #
      if debug
        Debug.log("inside response from openMail.Application.callWebService", response)
        
      if response.error
        # response has a parameter called "error"
        #
        if error_function
          error_function(response)
    		else if debug
          OIB.error(url, params, response)
      else
        # SUCCESSFUL RESPONSE
        #
        # response doesn't have a parameter called "error"
        # 
      	success_function(response)
	
	request: (oib_path, params, success_function, error_function, base_url) ->
    debug = !params["_hide_debug"]
    Debug.log("inside OIB.request: ", {"oib_path": oib_path, "params": JSON.stringify(params)}) if debug
  
    oib_url = OIB.url_from_path(oib_path, params, base_url)
    method = OIB.method_from_params(params)
    
    Debug.log("about to call OIB.ajax") if debug
    OIB.ajax(oib_url, method, params, success_function, error_function)
  
  method_from_params: (params) ->
    method = "GET"
    if !params.format
      params.format = 'json'
    if params.method
      method = params.method
      delete params.method
      
    params.version = params.version || "<%= @version %>"
    
    method
  
  url_from_path: (oib_path, params, base_url) ->
    oib_url = base_url || YMDP.Constants.base_url
  
    if !(oib_path && typeof(oib_path) == "string")
      throw("OIB.request must define oib_path")
      
    if !(params && typeof(params) == "object")
      throw("OIB.request must define params")
      
    oib_url + oib_path

  # overwrite this function locally if you need to
  #
	error: (url, params, response) ->
	  debug = !params["_hide_debug"]
	  
	  if debug
	    message = "OIB.error: " + JSON.stringify(response) + " calling url: " + url + "?" + $.param(params)
  	  Debug.error(message)
	
	# advance the user to the next state in the signup process
	#
  advance: (success_function, error_function) ->
    OIB.post "ymdp/state", {}, (response) ->
      Debug.log("Scanning.next success", response)
      if (success_function)
        success_function(response)
    , (response) ->
      Debug.error("Scanning.next error", response)
      if (error_function)
        error_function(response)