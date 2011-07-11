# DO NOT USE the @view instance variable in any files in /app/javascripts/base.
# The way they are cached makes it not safe to do so.

window.ABTesting = 
  on: true

  languages: <%= english_languages.to_json %>
  
  enable: ->
    ABTesting.on = true
  
  disable: ->
    ABTesting.on = false
  
  randomAB: ->
    Math.floor(Math.random()*2) ? "a" : "b"

  get: (content_id) ->
    url = "ymdp/experiment"
    
    OIB.get url, 
      "domain": View.domain
    , (response) ->
      ABTesting.success(content_id, response)
    , (response) ->
      ABTesting.error(response)

  
  post: (params) ->
    params = params || {}
    OIB.post "ymdp/view", params, (response) ->
      Debug.log("ABTesting.post success", response)
    , (response) ->
      Debug.error("ABTesting.post error", response)

  
  postView: (experimentId) ->
    params = 
      "var": ABTesting.variable
    
    if typeof(experimentId) != 'undefined'
      params["experiment_id"] = experimentId
    
    Debug.log("ABTesting.postView: ", params)
    ABTesting.post(params)

  
  setVariable: (value) ->
    ABTesting.variable = value

  apply: (content_id, language) ->
    if (ABTesting.on && $.inArray(language, ABTesting.languages) >= 0) 
      index = ABTesting.randomAB()
      ABTesting.setVariable(index)
    
      ABTesting.get(content_id)
     else
      YMDP.Init.showAndFinish()
    
  error: (data) ->
    Debug.log("applyError", data)
    if data.error != 3002
      Debug.error("Received body contents fetch error on page " + View.name + ": " + data.error + ' - ' + data.errorMsg)
    
    YMDP.Init.showAndFinish()
 
  success: (content_id, response) ->
    Debug.log("ABTesting.success", response)
    
    experiment = response.experiment
    
    if typeof(experiment) != 'undefined'
      content = ABTesting.content(experiment)
      experimentId = response.experiment.id

      ABTesting.postView(experimentId)
      ABTesting.replaceContents(content_id, content)        
    else 
      Debug.log("No experiment running")
    
    YMDP.Init.showAndFinish()
  
  replaceContents: (content_id, content) ->
    openmail.Application.filterHTML
      html: content, (response) ->
        if typeof(response.html) != 'undefined' && response.html != ''
          $("#" + content_id).html(response.html)
      
        YMDP.Init.showAndFinish()
  
  content: (experiment) ->
    experiment["content_" + ABTesting.variable]
