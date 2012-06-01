###
  APPLICATION

  # DO NOT USE the @view instance variable in any files in /app/javascripts/base.
  # The way they are cached makes it not safe to do so.

###

### 
  GLOBAL CONSTANTS 
###

window.View =
  application: "<%= @application_name %>"
  domain: "<%= @domain %>"
  page_loaded: false
  
  authorized: (user) ->
    return (user[View.application + "_user"])


window.unixTimeToDate = (unixtime) ->
  new Date(unixtime * 1000)

window.formatUnixDate = (unixtime) ->
  date = unixTimeToDate(unixtime)
  date.toString("MMMM d, yyyy")

String.prototype.capitalize = () ->
  this.charAt(0).toUpperCase() + this.slice(1)



window.YMDP =
  Constants: {}
  
  # Shows the error view.
  #
  # YMDP.showError({
  #   heading: "optional heading text can overwrite the error view's heading",
  #   message: "optional message can overwrite the view's first paragraph",
  #   retry: "hide"
  # })
  # 
  # Set the "retry" option to "hide" to hide the Retry button.
  #

  showError: (options) ->
    options = options || {}
  
    if options["heading"]
      $("#error_1").html(options["heading"])
    if options["message"]
      $("#error_2").html(options["message"])
    if options["retry"] && options["retry"] == "hide"
      $("#retry_button_container").hide()
  
    params = 
      "description": options["description"]
      "method_name": options["method"]
      "error": JSON.stringify(options["error"])
      "page": View.name
  
    Reporter.error(YMDP.guid, params)
    $('#main').hide()
    $('#utility').show()
    $('#loading').hide()
    $('#error').show()

  showLoading: () ->
    $('#main').hide()
    $('#utility').show()
    $('#error').hide()
    $('#loading').show()

  setTimeoutInSeconds: (callback_function, interval) ->
    setTimeout(callback_function, interval * 1000)

  showTranslations: () ->
    try
      Debug.log("begin YMDP.showTranslations")
      I18n.findAndTranslateAll()

      # define I18n.localTranslations in the view template
      I18n.localTranslations()
    
      Debug.log("end YMDP.showTranslations")
    catch omg
      Debug.error(omg.message)
