###
  LAUNCHING
 
  global to every view.  launches new views and closes the current one.

  # DO NOT USE the @view instance variable in any files in /app/javascripts/base.
  # The way they are cached makes it not safe to do so.

###

window.Launcher = {}

Launcher.launch = (view, title, type) ->
  openmail.Application.getParameters (response) ->
    title = I18n.t("APPLICATION_NAME")
    # don't try to relaunch current tab
    if response.data == null || response.data.view != view
      openmail.Application.openView
        id: view
        view: view
        target: type 
        title: title
        parameters:
          launchParams: Params.parameters
          view: view
        
      openmail.Application.closeView(null)

Launcher.launchView = (launch_view) ->  
  user = YMDP.user || {"state": "active"}
  
  switch user.state
    when "scanning"
      # formerly known as 'inspect'
      Launcher.launchScanning()
    when "summary" 
      Launcher.launchSummary()
    when "authorized" 
      # authorized but not yet 'signed in'
       YMDP.signInUser()
    when "new_active", "processing", "active"
       # activated but we have synced fewer than 80% of their messages
      # active, launch the view this method was intended for
      launch_view()
    else
      # other
      Launcher.launchAuthorize()


Launcher.launchTab = (view, title) ->
  Launcher.launch(view, title, "tab")

# User must be signed in for this page, we'll 
# sign them in if they don't have an OIB cookie
#
Launcher.launchActiveTab = (view, title) ->
  Launcher.launchTab(view, title)


Launcher.launchAuthorize = ->
  Launcher.launchTab("authorize", "Authorize")

Launcher.launchDeactivate = ->
  Launcher.launchHidden("deactivate", "Deactivate")

Launcher.launchHidden = (view, title) ->
  Launcher.launch(view, title, "hidden")

Launcher.l = (view) ->
  view = "launch" + view.capitalize()
  Launcher[view]()

Launcher.launchGoodbye = ->
  Launcher.launchTab("goodbye", "Goodbye")

Launcher.relaunchAuthorize = Launcher.launchAuthorize

Launcher.launchMaintenance = ->
  Launcher.launchTab("maintenance", "Maintenance")

Launcher.launchReauthorize = ->
  Launcher.launchTab("reauthorize", "Reauthorize")

Launcher.launchView = (launch_view) ->
  # get Yahoo! user's guid and ymail_wssid
  User.getGuidAndYmailWssid (guid, ymail_wssid) ->
           
    # call /ymdp/verify and return data about the user
    User.verify (user) ->

      YMDP.login = user.login
    
      switch user.state
        when "scanning"
          # formerly known as 'inspect'
          Launcher.launchScanning()
        when "summary"
          Launcher.launchSummary()
        when "authorized"
          # authorized but not yet 'signed in'
           YMDP.signInUser()
        when "new_active", "processing", "active"
           # no messages processed yet
           # activated but we have synced fewer than 80% of their messages
          # active, launch the view this method was intended for
          launch_view()
        else
          # other
          Launcher.launchAuthorize()

Launcher.launchMain = ->
  Launcher.launchView(Launcher.launchFolders)
