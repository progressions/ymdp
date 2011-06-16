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
	// - a base URL to use, if you don't want this call going to YMDP.Constants.base_url
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
          YMDP.showError(
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
          YMDP.showError(
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
	  var debug;
	  
	  params = params || {};
	  params["application"] = View.application;
	  
	  debug = !params["_hide_debug"];
	  
	  if (debug) {
      Debug.log("OIB.ajax: About to call openmail.Application.callWebService: ", {
        "method": method,
        "url": url + "?" + $.param(params)
      });
    }
    
    openmail.Application.callWebService(
    {
    	url: url,
    	method: method,
    	parameters: params
    },
    function(response) {
      // response from Ajax call was a 200 response
      //
      if (debug) {
        Debug.log("inside response from openMail.Application.callWebService", response);
      }
      if (response.error) {
        // response has a parameter called "error"
        //
        if (error_function) {
    		  error_function(response);
    		} else {
    		  if (debug) {
            OIB.error(url, params, response);
          }
        }
      } else {
        // SUCCESSFUL RESPONSE
        //
        // response doesn't have a parameter called "error"
        // 
      	success_function(response);
      }
    });  
	},
	
	request: function(oib_path, params, success_function, error_function, base_url) {
    var oib_url, method, debug;
	  
	  debug = !params["_hide_debug"];
	  
	  if (debug) {
      Debug.log("inside OIB.request: ", {
        "oib_path": oib_path,
        "params": YAHOO.lang.JSON.stringify(params)
      });
    }
  
    oib_url = base_url ? base_url : YMDP.Constants.base_url;
  
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
  
    if (debug) {
      Debug.log("about to call OIB.ajax");
    }
    
    OIB.ajax(oib_url, method, params, success_function, error_function);
  },
	
  // overwrite this function locally if you need to
	error: function(url, params, response) {
	  var message, debug;
	  
	  debug = !params["_hide_debug"];
	  
	  if (debug) {
	    message = "OIB.error: " + YAHOO.lang.JSON.stringify(response) + " calling url: " + url + "?" + $.param(params);
  	  Debug.error(message);
	  }
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
