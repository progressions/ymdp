### 

INITIALIZER CODE

###

# Adds behaviors/observers to elements on the page
#

YMDP.Init = {}

YMDP.Init.addBehaviors = ->
	# overwrite this function locally


# hide the loading screen and show the main body of the summary
YMDP.Init.show = ->
  Debug.log("YMDP.Init.show")
  $('#utility').hide()
  $('#error').hide()
  $('#loading').hide()
  $('#main').show()


# Local initializer.  When your page starts up, this method will be called after fetching the user's guid and ymail wssid.
#
YMDP.Init.local = ->
  throw("This hasn't been overwritten.")
	# overwrite this function locally


# To be run before any other initializers have run.
#
YMDP.Init.before = ->
	# overwrite this function locally

# Main startup code. Overwrite this function to execute after YMDP.Init.before and before YMDP.Init.after.
#
YMDP.Init.startup = ->
  Debug.log("init.startup")
  # gets the user
  User.getGuid (guid) ->
	  Reporter.reportCurrentView(guid)
	  callback = ->
      try
        YMDP.Init.local()
      catch omg
        Debug.error("Error in YMDP.Init.local", omg)
        YMDP.showError()
      
    Debug.log("YMDP.Init.startup YMDP.guid: #{YMDP.guid}")
    User.getState(callback, callback)


YMDP.Init.abTesting = ->
  # to enable abTesting in your view, overwrite this file locally.
  # 
  # be sure to finish your post-Ajax callback with YMDP.Init.show()
  #
  YMDP.Init.show()
  YMDP.Init.after()


# Finishing code. Runs after startup, executes translations and behaviors.  Shows the page and then 
# runs the A/B testing callback, which in turn will execute the last callbacks.
#
YMDP.Init.finish = ->
  Debug.log("init.finish for view " + View.name)
  YMDP.showTranslations()
  YMDP.Init.addBehaviors()
  YMDP.Init.abTesting()
  View.page_loaded = true
  Debug.log("finished init.finish for view " + View.name)


# Post-initalizer. Very last thing that runs, after content has been shown.
#
YMDP.Init.after = ->
	# overwrite this function locally


YMDP.setJSON = ->
  if typeof(JSON) != 'undefined'
    true
  
  if typeof(YUI) != 'undefined'
    YUI().use 'json', (Y) ->
      window.JSON = Y.JSON
      
  else if typeof(YAHOO) != 'undefined' && typeof(YAHOO.lang) != 'undefined'
    window.JSON = YAHOO.lang.JSON
  

# Execute the before, startup and after methods. Do not overwrite. (Change YMDP.Init.startup to create a custom initializer.)
YMDP.init = ->
  try
    YMDP.setJSON() # must set JSON first because Debug uses it
    Debug.log("OIB.init for view " + View.name, "<%= @message %>")
    Logger.init()
    Tags.init()
    YMDP.Init.browser()
    YMDP.Init.resources()
    I18n.addLanguageToBody()
    I18n.translateLoading()
    I18n.translateError()
    YMDP.Init.before()
    YMDP.Init.startup()
  catch omg
    Debug.error(omg.message)
  


YMDP.Init.browser = ->
  if $.browser.webkit
    $('body').addClass('webkit')
  if $.browser.safari
    $('body').addClass('safari')
  if $.browser.msie
    $('body').addClass('msie')
  if $.browser.mozilla
    $('body').addClass('mozilla')
  $('body').addClass("version_#{$.browser.version}")
  

YMDP.Init.resources = ->
  Debug.log("about to call I18n.setResources")
  
  I18n.availableLanguages = <%= supported_languages.to_json %>

  I18n.currentLanguage = OpenMailIntl.findBestLanguage(I18n.availableLanguages)
  
  I18n.setResources()

  Debug.log("finished calling I18n.setResources")


# Contains the last two callbacks, to show the page contents and run post-show function.  Do not overwrite.
YMDP.Init.showAndFinish = ->
  Debug.log("YMDP.Init.showAndFinish")
  YMDP.Init.show()
  YMDP.Init.after()

YMDP.Init.upgradeCheck = (success_callback, failure_callback) ->
  # test for Minty
  #
  openmail.Application.getParameters (response) ->
    if response.version == "2"
      # Minty-only code goes here

      Debug.log("Minty found")
      
      success_callback()
    else
      # non-Minty
      
      if failure_callback
        failure_callback()
      else
        YMDP.Init.upgrade()

YMDP.Init.upgrade = () ->
  YMDP.showTranslations()
	
  View.page_loaded = true
  
  $('#loading').hide()
  $('#error').hide()
  $('#upgrade').show()
