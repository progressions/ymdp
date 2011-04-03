var Params = {
  names: ["invitation", "page"],
  parameters: {},
  
  init: function(launchParams) {
    launchParams = launchParams || {};
    Debug.log("Params.init", launchParams);
    
    try {
      if (launchParams) {
        Params.parameters = launchParams;
      } else {
        Params.parameters = {};
      }
    } catch(wtf) {
      Debug.error(wtf);
    }
  },
  
  get: function(name) {
    Debug.log("Params.get", name);
    var index, result;
    
    try {
      index = Params.names.indexOf(name);
    
      if (index >= 0) {
        result = Params.parameters["param" + index];
      }
    } catch(wtf) {
      Debug.error(wtf);
    }
    return result;
  }
};