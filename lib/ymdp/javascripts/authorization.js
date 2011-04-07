/*
  AUTHORIZE USER
  			  
  Authorize and sign in the user.
*/

var Authorize;

Authorize = {
  init: function(guid, default_state, params) {
    Debug.log("Authorize.init");
    params = params || {};
    if (Params.get("invitation")) {
      params["invitation"] = Params.get("invitation");
    }
    params["application"] = View.application;
    Authorize.url = YAHOO.constants.controller_url + "/authorize/" + guid;
    Authorize.locale = params.locale;
    Authorize.default_state = default_state;
    
    Authorize.params = params;
  },
  
  assignUrl: function(url) {
    url = url || Authorize.url;
    url = url + "?" + Object.toQueryString(Authorize.params);
    if ($('get_started_1')) {
      $('get_started_1').href = url;
      $('get_started_1').setAttribute("target", "_blank");
    }
    if ($('get_started_2')) {
      $('get_started_2').href = url;
      $('get_started_2').setAttribute("target", "_blank");
    }
    $$('a.get_started').each(function(element) {
      element = $(element);
      element.href = url;
      element.setAttribute("target", "_blank");
    });
  },
  
  authorize: function() {
    Debug.log("Authorize.authorize");
    YAHOO.oib.getUserState(function(response) {
      if (Authorize.authorized(response)) {
        Authorize.confirm();
      } else {
        Debug.log("About to startScanning");
        Authorize.startScanning();
      }
    });
  },
  
  startScanning: function() {
    Debug.log("Authorize.startScanning", Authorize.scanner);
    if (!Authorize.scanner) {
      Debug.log("Authorize.scanner doesnt exist", Authorize.scanner);
      Authorize.scanner = new PeriodicalExecuter(Authorize.scan, 5);
    } else {
      Debug.log("Authorize.scanner does exist", Authorize.scanner);
    }
  },
  
  authorized: function(response) {
    Debug.log("Authorize.authorized", response);
    return !!(response.state !== Authorize.default_state && View.authorized(response));
  },
  
  confirm: YAHOO.oib.confirm,
  
  scan: function(pe) {
    Debug.log("Authorize.scan", pe);
    if (Authorize.stop_scanning) {
      Debug.log("Authorize.stop_scanning is true", Authorize.stop_scanning);
      pe.stop();
    } else {
      Debug.log("Authorize.stop_scanning is not true", Authorize.stop_scanning);
    }
    
    Debug.log("About to getUserState");
    
    YAHOO.oib.getUserState(function(response) {
      Debug.log("inside Authorize.scan's getUserState callback", response);
      if (response.state !== Authorize.default_state) {
        Debug.log("not default state, about to Authorize.confirm()");
        
        Authorize.confirm();
        if (pe) {
          Debug.log("pe", pe);
          pe.stop();
        }
        Authorize.scanner = undefined;
        Debug.log("just set Authorize.scanner to undefined");
      }
    }, function(response) {
      // error function
      Debug.error("Error in Authorize.scan's getUserState", response);
      
      if (pe) {
        pe.stop();
      }
    }); 
  },
  
  addBehaviors: function() {
    Debug.log("Authorize.addBehaviors");
    if ($("get_started_1")) {
      Debug.log("get_started_1");
      $("get_started_1").observe("click", Authorize.authorize);
    }
    if ($("get_started_2")) {
      Debug.log("get_started_2");
      $("get_started_2").observe("click", Authorize.authorize);
    }
    $$(".get_started").each(function(element) {
      element.observe("click", Authorize.authorize);
    });    
  },
  
  verify: function() {
		// call /ymdp/verify and return data about the user
		YAHOO.oib.verifyUser(function(user) {
      Debug.log("inside YAHOO.oib.verifyUser callback", user);
      
      YAHOO.oib.user = user;
		  YAHOO.oib.login = user.login;
      YAHOO.init.switchOnState(user);
    }, function(response) {
      // call to ymdp/verify was not a 200 response, show error
      YAHOO.oib.showError({
        "method_name": "YAHOO.oib.verifyUser",
        "description": "error response"
      });
    });
  }
};

