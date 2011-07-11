window.Params = 
  names: ["invitation", "page", "cc"]
  parameters: {}
  
  init: (launchParams) ->
    launchParams = launchParams || {}
    Debug.log("Params.init", launchParams)
    
    if launchParams
      Params.parameters = launchParams
    else
      Params.parameters = {}
  
  get: (name) ->
    Debug.log("Params.get", name)

    index = $.inArray(name, Params.names)
  
    if index >= 0
      result = Params.parameters["param" + index]
      
    result