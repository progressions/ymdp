var Data;

Data = {
  // values cannot be longer than 255 chars
  //
  store: function(data, success_function, error_function) {
    Debug.log("Data.store", data);
    
    var keys = {
      "keys": data
    };
    openmail.Application.setData(keys, function(response) {
      Debug.log("openmail.Application.setData response", response);

      if (response.error && (response.error !== YAHOO.openmail.ERR_NONE)) {
        // storage error detected
        Debug.error("Error saving data", response);
        if (error_function) {
          error_function(response);
        }
      } else {
        if (success_function) {
          success_function(response);
        }
      }
    });
  },
  
  // keys must be an array
  //
  fetch: function(keys, success_function, error_function) {
    Debug.log("Data.fetch", keys);
    
    keys = {
      "keys": keys
    };
    
    openmail.Application.getData(keys, function(response) {
      Debug.log("Inside openmail.Application.getData callback", response);
    
      if (response.error && (response.error !== YAHOO.openmail.ERR_NONE)) {
        Debug.error("Error retrieving data", response);
        if (error_function) {
          error_function(response);
        }
      } else {
        Debug.log("success in openmail.Application.getData", response);
        if (success_function) {
          success_function(response);
        }
      }
    });
  },
  
  clear: function() {
    Data.store({
      "ymail_wssid": null
    }, function(response) {
      YMDP.guid = null;
      YMDP.ymail_wssid = null;      
    });
  }
};
