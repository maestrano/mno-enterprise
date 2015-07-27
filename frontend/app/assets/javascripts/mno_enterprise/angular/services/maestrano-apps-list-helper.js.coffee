angular.module('maestrano.services.apps-list-helper', []).factory( 'AppsListHelper', [
  'AssetPath','$window','MsgBus'
  (AssetPath,$window,MsgBus) ->

    service = {}

    class AppsListHelperClass
      constructor: (@controlType) ->
        self = this

      actionProgressClass: (instance) ->
        realStatus = instance.status
        realStatus = 'provisioning' if realStatus == 'staged'
        realStatus = 'starting' if realStatus == 'restarting'
        realStatus = 'terminated' unless realStatus

        if realStatus == 'updating'
          return "progress-mno-warning progress-striped active"
        else if realStatus == 'running'
          return "progress-mno-success"
        else if realStatus == 'starting' || realStatus == 'provisioning'
          return "progress-mno-success progress-striped active"
        else if realStatus == 'terminating'
          return "progress-mno-danger progress-striped active"
        else if realStatus == 'terminated'
          return "progress-mno-danger"
        else if realStatus == 'stopping'
          return "progress-mno-none progress-striped active"
        else
          # includes "stopping" and "stopped" state
          return "progress-mno-none"

      # Return the action progression in percent
      # unit: specifies the unit that should be appended
      # to the result. If null then the result is an integer.
      # Eg. actionProgress(intance, '%') -> 95%
      actionProgress: (instance, unit = null) ->
        # Get out of there if the bar is not shown
        if !this.isProgressBarShown(instance)
          return 0

        # Get the relevant status from an actionProgress
        # point of view
        realStatus = instance.status
        realStatus = 'provisioning' if realStatus == 'staged'
        realStatus = 'starting' if realStatus == 'restarting'
        realStatus = 'terminated' unless realStatus

        if (realStatus  == 'stopped' || realStatus == 'running' || realStatus == 'terminated')
          percent = 100
          percent = "#{percent}#{unit}" if unit?
          return percent
        else if realStatus  == 'updating'
          percent = 70
          percent = "#{percent}#{unit}" if unit?
          return percent

        # Get the maxDuration (seconds) and referenceField based on
        # the action being performed
        maxDuration = instance.durations[realStatus]
        referenceField = {
          'provisioning': 'createdAt',
          'starting': 'startedAt',
          'stopping': 'stoppedAt',
          'terminating': 'terminatedAt'
          }[realStatus]

        # Get the action elapsed time in seconds
        startTime = new Date(instance[referenceField])
        endTime = new Date((new Date()).getTime() - $window.clientTimeOffset) #remove Client-Server time offset
        elapsedTime = (endTime.getTime() - startTime.getTime()) / 1000

        # Calculate the percentage
        # Max value is 95% / Min value is 5%
        percent = Math.round((elapsedTime / maxDuration)*100)
        percent = Math.min(percent, 95)
        percent = Math.max(percent, 5)
        percent = "#{percent}#{unit}" if unit?
        return percent

      ownerLabelFor: (instance) ->
        return {
          'User': 'You',
          'Organization': instance.ownerLabel
        }[instance.ownerType]

      isAppActionUrlEnabled: (instance) ->
        return (instance && instance.status != 'terminating' && instance.status != 'terminated')

      appActionUrl: (instance) ->
        "/mnoe/launch/#{instance.uid}"

      appLoaderPath: (instance) ->
        if instance.status == 'running'
          AssetPath['loaders/app_label_running.png']
        else if instance.status == 'starting' || instance.status == 'staged' || instance.status == 'provisioning'
          AssetPath['loaders/app_label_starting.gif']
        else if instance.status == 'stopping'
          AssetPath['loaders/app_label_stopping.gif']
        else if instance.status == 'stopped'
          AssetPath['loaders/app_label_stopped.png']
        else if instance.status == 'terminating'
          AssetPath['loaders/app_label_terminating.gif']
        else if instance.status == 'terminated'
          AssetPath['loaders/app_label_terminated.png']
        else # upgrading/downgrading/updating etc.
          AssetPath['loaders/app_label_stopping.gif']

      appLoaderStatus: (instance) ->
        if instance.status == 'running'
          return '<span class="mgreen">online</span>'
        else if instance.status == 'starting'
          return '<span class="mgreen">loading</span>'
        else if instance.status == 'staged' || instance.status == 'provisioning'
          return '<span class="mgreen">preparing</span>'
        else if instance.status == 'stopping'
          return '<span class="text-warning">idling</span>'
        else if instance.status == 'stopped'
          return '<span class="mgrey">offline</span>'
        else if instance.status == 'terminating'
          return '<span class="mred">terminating</span>'
        else if instance.status == 'terminated'
          return '<span class="mred">terminated</span>'
        else # upgrading/downgrading/updating etc.
          return "<span class='text-warning'>#{instance.status}</span>"

      isLaunchHidden: (instance) ->
        instance.status == 'terminating' ||
        instance.status == 'terminated' ||
        this.isOauthConnectBtnShown(instance) ||
        this.isNewOfficeApp(instance)

      # Deprecated?
      isStartShown: (instance) ->
        if instance.stack? && instance.stack.match(/^(cloud|connector)$/i)
          return false
        else
          (@controlType == 'ops' || @controlType == 'dashboard') &&
          instance &&
          instance.canStart &&
          instance.status == 'stopped'

      # Deprecated?
      isStopShown: (instance) ->
        if instance.stack? && instance.stack.match(/^(cloud|connector)$/i)
          return false
        else
          (@controlType == 'ops' || @controlType == 'dashboard') &&
          instance &&
          instance.billingType == 'hourly' &&
          instance.canStop &&
          instance.status == 'running'

      isTimerButtonShown: (instance) ->
        this.isStopShown(instance) && instance.autostopAt?

      isRestartShown: (instance) ->
        if instance.stack? && instance.stack.match(/^(cloud|connector)$/i)
          return false
        else
          (@controlType == 'manage' || @controlType == 'dashboard') &&
          instance &&
          instance.status == 'running'

      isDeleteShown: (instance) ->
        (@controlType == 'manage' || @controlType == 'dashboard') &&
        instance &&
        instance.canTerminate &&
        (instance.status == 'stopped' ||
        instance.status == 'running')


      isTransferShown: (instance) ->
        (@controlType == 'manage' || @controlType == 'dashboard') &&
        instance &&
        !instance.personal &&
        instance.status != 'terminating' &&
        instance.status != 'terminated' &&
        instance.canTerminate

      isProgressBarShown: (instance) ->
        if @controlType == 'dashboard' then return true
        else
          @controlType == 'ops' &&
          instance &&
          (
            instance.status == 'staged' ||
            instance.status == 'provisioning' ||
            instance.status == 'starting' ||
            instance.status == 'restarting' ||
            instance.status == 'stopping' ||
            instance.status == 'terminating'
          )

      isChangeGradeShown: (instance) ->
        if instance.stack? && instance.stack.match(/^(cloud|connector)$/i)
          return false
        else
          (@controlType == 'manage' || @controlType == 'dashboard') &&
          instance &&
          instance.status != 'terminating' &&
          instance.status != 'terminated' &&
          (
            !instance.appChangeRequest? ||
            (instance.appChangeRequest &&
             instance.appChangeRequest.status == 'performed'
             )
          )

      isViewChangeGradeShown: (instance) ->
        (@controlType == 'manage' || @controlType == 'dashboard') &&
        instance.status != 'terminating' &&
        instance.status != 'terminated' &&
        instance.appChangeRequest &&
        instance.appChangeRequest.status != 'cancelled'

      classForViewChangeButton: (instance) ->
        if instance.appChangeRequest
          status = instance.appChangeRequest.status
          return 'fbtn fbtn-mini fbtn-success' if status == 'performed'
          return 'fbtn fbtn-mini fbtn-warning' if status == 'pending' || status == 'performing'


      viewChangeGradeLabel: (instance) ->
        if instance.appChangeRequest
          status = instance.appChangeRequest.status
          return 'Recent change' if status == 'performed'
          return 'Change pending' if status == 'pending'
          return 'Changing' if status == 'performing'

      isChangeLoadingShown: (instance) ->
        instance.appChangeRequest && instance.appChangeRequest.status == 'performing'

      isManageActionsShown: (instance) ->
        this.isChangeGradeShown(instance) ||
        this.isRestartShown(instance) ||
        this.isDeleteShown(instance)

      openHelpText: (instance) ->
        msg = "Open your app in a new tab"
        if instance.ssoEnabled
          msg += "<br><br><em>You will automatically be logged in via your maestrano account</em>"
        else if instance.firstCredentials && instance.firstCredentials.login
          msg += "<br><br>If this is the first time then use"
          msg += "<br><b class=\"morange\">Login</b>: #{instance.firstCredentials.login}"
          if instance.firstCredentials.password
            msg += "<br><b class=\"morange\">Password</b>: #{instance.firstCredentials.password}"
          else
            msg += "<br><b class=\"morange\">Password</b>: <em>Leave blank</em>"
        return msg

      kcPath: (instance) ->
        "/knowledge_center/apps/#{instance.appId}"

      isOverlayRequired: (instance) ->
        instance.stack == 'connector'

      isQuickBooksConnectShown: (instance) ->
        instance.stack == 'connector' && instance.app_nid == 'quickbooks' && !instance.oauth_keys_valid

      isXeroConnectShown: (instance) ->
        instance.stack == 'connector' && instance.app_nid == 'xero' && !instance.oauth_keys_valid

      isMYOBConnectShown: (instance) ->
        instance.stack == 'connector' && instance.app_nid == 'myob' && !instance.oauth_keys_valid

      isOauthConnectBtnShown: (instance) ->
        instance.app_nid != 'office-365' &&
        instance.stack == 'connector' &&
        !instance.oauth_keys_valid

      connectToQuickBooks: (instance) ->
        instance.status = 'updating'
        intuit.ipp.anywhere.grantUrl = this.quickbooksGrantUrl(instance) + '?popup=true'
        intuit.ipp.anywhere.controller.onConnectToIntuitClicked()

      isDataSyncShown: (instance) ->
        instance.stack == 'connector' && instance.oauth_keys_valid

      isDataDisconnectShown: (instance) ->
        instance.stack == 'connector' && instance.oauth_keys_valid

      quickbooksGrantUrl: (instance) ->
        arr = $window.location.href.split("/");
        url = $window.location.protocol + '//' + arr[2]
        url += this.dataSyncPath(instance)
        return url

      isMicrosoftSetupShown: (instance) ->
        instance.stack == 'connector' && instance.appNid == 'office-365' && (moment(instance.createdAt) > moment().subtract({weeks:2}))

      isNewOfficeApp: (instance) ->
        newApp = (MsgBus.subscribe('params'))().new_app
        instance.stack == 'connector' && instance.appNid == 'office-365' && newApp && (moment(instance.createdAt) > moment().subtract({minutes:5}))

      microsoftTrialUrl: (instance) ->
        return instance.microsoftTrialUrl

      companyName: (instance) ->
        if instance.stack == 'connector' && instance.oauth_keys_valid && instance.oauth_company_name
          return instance.oauth_company_name
        false

      connectorVersion: (instance) ->
        if instance.stack == 'connector' && instance.oauth_keys_valid && instance.connectorVersion
          return capitalize(instance.connectorVersion)
        false

      dataSyncPath: (instance) ->
        "/mnoe/webhook/oauth/#{instance.uid}/sync"

      oAuthConnectPath: (instance)->
        "/mnoe/webhook/oauth/#{instance.uid}/authorize"

      dataDisconnectPath: (instance) ->
        "/mnoe/webhook/oauth/#{instance.uid}/disconnect"

      dataDisconnectClick: (instance) ->
        $window.location.href = this.dataDisconnectPath(instance)

      myobAccountRightConnectPath: (instance) ->
        "/webhook/myob/#{instance.uid}/authorize?version=account_right"

      myobEssentialsConnectPath: (instance) ->
        "/webhook/myob/#{instance.uid}/authorize?version=essentials"

      capitalize = (string) ->
        string = string.replace("_", " ")
        string.replace /\w\S*/g, (txt) ->
          txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()

    service.new = (controlType = 'dashboard') ->
      return new AppsListHelperClass(controlType)

    return service

])
