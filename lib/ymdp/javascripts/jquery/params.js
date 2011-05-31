var Params = {
  names: ["invitation", "page"],
  parameters: {},
  
  init: function(launchParams) {
    launchParams = launchParams || {};
    Debug.log("Params.init", launchParams);
    
    if (launchParams) {
      Params.parameters = launchParams;
    } else {
      Params.parameters = {};
    }
  },
  
  get: function(name) {
    Debug.log("Params.get", name);
    var index, result;

    index = $.inArray(name, Params.names);
  
    if (index >= 0) {
      result = Params.parameters["param" + index];
    }
    return result;
  }
};