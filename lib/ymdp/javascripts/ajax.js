/*
	  CALL OIB

	  global to every view.  sends Ajax call to OtherInbox.
*/

	// send an Ajax call to OtherInbox.
	// takes as parameters:
	// - the path to call
	// - any additional query string params
	// - a callback function to run when the Ajax call is a success
	// - an optional error function
	// - a base URL to use, if you don't want this call going to YAHOO.constants.base_url
	// TODO refactor this function to take a second params hash where we could stick success_function, error_function, and base_url

OIB = {
	get: function(oib_path, params, success_function, error_function, base_url) {
		params.method = "GET";
		OIB.call(oib_path, params, success_function, error_function, base_url);
	},

	post: function(oib_path, params, success_function, error_function, base_url) {
		params.method = "POST";
		OIB.call(oib_path, params, success_function, error_function, base_url);
	},
	
	call: function(oib_path, params, success_function, error_function, base_url) {
	  var success;
	  
	  success = function(response) {
      response = YAHOO.lang.JSON.parse(response.data);
      if (response.error) {
        if (error_function) {
          error_function(response);
        } else {
          Debug.error("No error_function", response);
          YAHOO.oib.showError(
            {
              "method": "OIB.call",
              "description": "error callback"
            }
          ); // OIB.call response: error
        }
      } else {
        if (success_function) {
          success_function(response); 
        } else {
          Debug.error("no success function", response);
          YAHOO.oib.showError(
            {
              "method": "OIB.call",
              "description": "success callback error"
            }
          ); // OIB.call response: success error
        }
      }
    };
	  OIB.request(oib_path, params, success, error_function, base_url);
	},
	
	ajax_response: false,
	
	ajax: function(url, method, params, success_function, error_function) {
	  params = params || {};
	  params["application"] = View.application;
	  
    Debug.log("OIB.ajax: About to call openmail.Application.callWebService: ", {
      "method": method,
      "url": url + "?" + Object.toQueryString(params)
    });
    
    openmail.Application.callWebService(
    {
    	url: url,
    	method: method,
    	parameters: params
    },
    function(response) {
      // response from Ajax call was a 200 response
      //
      Debug.log("inside response from openMail.Application.callWebService", response);
      if (response.error) {
        // response has a parameter called "error"
        //
        if (error_function) {
    		  error_function(response);
    		} else {
          OIB.error(url, params, response);
        }
      } else {
        // SUCCESSFUL RESPONSE
        //
        // response doesn't have a parameter called "error"
        // 
        Debug.log("success response inside openMail.Application.callWebService", response);
    		try {
        	success_function(response);
    		} catch(e) {
    		  Debug.log("Error in OIB.request success function", e);
    		  YAHOO.oib.showError({
    		    "method": "OIB.request",
    		    "description": "exception caught in OIB.request success callback",
    		    "error": e
    		  });
    		}
      }
    });  
	},
	
	request: function(oib_path, params, success_function, error_function, base_url) {
    Debug.log("inside OIB.request: ", {
      "oib_path": oib_path,
      "params": Object.toJSON(params)
    });
    var oib_url, method;
  
    oib_url = base_url ? base_url : YAHOO.constants.base_url;
  
    if (!(oib_path && typeof(oib_path) === "string")) {
      throw("OIB.request must define oib_path");
    }
    if (!(params && typeof(params) === "object")) {
      throw("OIB.request must define params");
    }
  
   	oib_url = oib_url + oib_path;
    method = "GET";
    if (!params.format) {
      params.format = 'json';
    }
    if (params.method) {
      method = params.method;
      delete params.method;
    }
    params.version = params.version || <%= @version %>;
  
    Debug.log("about to call OIB.ajax");
    
    OIB.ajax(oib_url, method, params, success_function, error_function);
  },
	
  // overwrite this function locally if you need to
	error: function(url, params, response) {
	  var message;
	  
	  message = "OIB.error: " + Object.toJSON(response) + " calling url: " + url + "?" + Object.toQueryString(params);
	  Debug.error(message);
	},
	
	// advance the user to the next state in the signup process
	//
  advance: function(success_function, error_function) {
    OIB.post("ymdp/state", {}, function(response) {
      Debug.log("Scanning.next success", response);
      if (success_function) {
        success_function(response);
      }
    }, function(response) {
      Debug.error("Scanning.next error", response);
      if (error_function) {
        error_function(response);
      }
    });
  }
};
