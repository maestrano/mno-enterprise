module = angular.module('maestrano.components.mno-shopping-cart',['maestrano.assets'])

#============================================
# Component 'Sync config'
#============================================
# attributes
# mnoShoppingCart = <true|false> (whether the cart is open or not)
# bundle = { app_instances: [{app: { id: 1 }}] } (initialize cart with bundle)
# config = {
#   afterCheckoutFn: function to perform instead of just redirecting to dashboard
#                    the function accept the following argument: (cart)
#                    where 'cart' is ShoppingCart.data
#   organizationId: Organization to select by default on "Select an organization" screen
# }
#
module.controller('MnoShoppingCartCtrl',[
  '$scope', '$rootScope', '$http', '$q','$window', '$modal', 'TemplatePath', 'ShoppingCart', 'Utilities', 'CurrentUserSvc'
  ($scope, $rootScope, $http, $q, $window, $modal, TemplatePath, ShoppingCart, Utilities, CurrentUserSvc) ->
    $scope.modal = modal = {}
    $scope.forms = {}
    $scope.assetPath = $rootScope.assetPath
    $scope.cartSvc = cartSvc = ShoppingCart

    currentUserInfos = CurrentUserSvc
    currentUserInfos.loadDocument()
    currentUserInfos.then ->
      $scope.country_code = currentUserInfos.document.user.country_code

    #=======================================================
    # Configuration
    #=======================================================
    modal.config = {
      instance: {
        backdrop: 'static'
        templateUrl: TemplatePath['mno_enterprise/maestrano-components/shopping_cart.html']
        size: 'lg'
        windowClass: 'inverse'
        scope: $scope
      }
    }

    #=======================================================
    # Scope helpers
    #=======================================================
    $scope.formatMoney = (priceObj)->
      accounting.formatMoney(priceObj.value,priceObj.options)

    # Either perform a provided action or perform the default
    # one
    $scope.afterCheckoutAction = ->
      self = $scope
      if (c = self.config()) && angular.isFunction(c.afterCheckoutFn)
        c.afterCheckoutFn(ShoppingCart.data)
      else
        path = '/myspace'
        param = "?new_app=true"
        if (d = ShoppingCart.data) && (o = d.organization) && (o.id)
          param = "#{param}&dhbRefId=#{o.id}"

        forceReload = ($window.location.pathname == path)
        $window.location.href = "#{path}#/#{param}"

        # Make sure we force a page reload if we're going to
        # stay on the same page
        $window.location.reload(true) if forceReload

    #=======================================================
    # View Helpers
    #=======================================================
    # Open the modal window
    modal.open = ->
      self = modal
      self.setLoading()
      self.$instance = $modal.open(modal.config.instance)
      self.$signedInOrUpViaPopup = false

      cartSvc.start($scope.bundle()).then ->
        self[self.currentStep()].initialize()
        self.setReady()

    # Close the modal window
    # If the user signed in during the process
    # then the page gets reloaded to make sure
    # that the navbar reflects the fact that
    # the user is logged in
    modal.close = ->
      self = modal
      self.$instance.close()
      $scope.mnoShoppingCart = false
      if self.$signedInOrUpViaPopup
        $window.location.reload(true)

    modal.prevStep = ->
      cartSvc.state.prevStep

    modal.currentStep = ->
      cartSvc.state.step

    modal.currentSubStep = ->
      cartSvc.state.subStep

    modal.setLoading = (text = '') ->
      modal.$loadingText = text
      modal.$loading = true

    modal.setReady = ->
      modal.$loadingText = ''
      modal.$loading = false

    modal.isLoading = ->
      modal.$loading == true

    modal.validCountries = ->
      $window.Countries

    modal.isNextDisabled = ->
      self = modal
      if angular.isObject(self[self.currentStep()]) && angular.isFunction(self[self.currentStep()].isNextDisabled)
        self[self.currentStep()].isNextDisabled()
      else
        false

    modal.isBackDisabled = ->
      false

    # Move the shopping cart to the next step
    modal.next = ->
      self = modal
      self.errors = ''
      self[self.currentStep()].next().then(
        (success) ->
          if cartSvc.next()?
            self[self.currentStep()].initialize()
        (error) ->
      )

    # Move the shopping cart back to the previous
    # step
    modal.back = ->
      self = modal
      self.errors = ''
      if cartSvc.back()?
        self[self.currentStep()].initialize()

    # Do we show the order summary on the right?
    modal.isSideAreaShown = ->
      cartSvc.isOrderShown()

    modal.mainAreaClass = ->
      if modal.isSideAreaShown() then 'col-sm-8' else 'col-sm-12'

    modal.sideAreaClass = ->
      'col-sm-4'

    #=======================================================
    # Funnel
    #=======================================================
    modal.funnel = funnel = {}

    # Do not display funnel on login/signup/choose orga pages
    funnel.isShown = ->
      cartSvc.isFunnelShown()

    # Determine whether we should make provided step
    # active or not
    funnel.classForStep = (stepNumber) ->
      if cartSvc.stepNumber() == stepNumber then 'active' else ''

    #=======================================================
    # Side Order - Order Summary
    #=======================================================
    modal.sideOrder = sideOrder = {}

    sideOrder.setLoading = ->
      sideOrder.$loading = true

    sideOrder.setReady = ->
      sideOrder.$loading = false

    sideOrder.isLoading = ->
      sideOrder.$loading == true

    sideOrder.getItemsFor = (billing) ->
      cartSvc.cart.orderList[billing]

    sideOrder.showItemsFor = (billing) ->
      self = sideOrder
      if billing == 'pay_as_you_go'
        return self.showItemsFor('hourly') || self.showItemsFor('variable') || self.showItemsFor('external')
      else
        return angular.isArray(self.getItemsFor(billing)) &&
        self.getItemsFor(billing).length > 0

    sideOrder.currentMode = ->
      cartSvc.sideAreaMode()

    # Return the specified type of
    # totals
    # Accepted types are:
    # - adhoc
    # - hourly
    # - monthly (reduction applied)
    # - monthlyRaw (no reduc)
    # - upfront (reduction applied)
    # - upfrontRaw (no reduc)
    # - upfrontSavings
    # - upfrontWithTax
    # - upfrontTax
    # - upfrontBeforeCredit
    # - supportCredit
    sideOrder.total = (type, opts = { format: true }) ->
      val = cartSvc.cart.total[type]
      if opts.format
        return accounting.formatMoney(val.value,val.options)
      else
        return val

    # Proceed to checkout and redirect
    # users to their dashboard
    # Do not redirect if an invoice is to be
    # downloaded
    sideOrder.checkout = (creditCard = {})->
      cartSvc.checkout(creditCard)

    # Return a cart setting
    # Accepted types are:
    # - prepayMonths
    # - reductionPercent
    # - underFreeTrial
    # - freeTrialEligible
    # - creditCardRequired
    # - monthlyCreditAvailable
    sideOrder.setting = (type) ->
      cartSvc.cart.setting[type]

    # Whether to show the discounted price or not
    sideOrder.isDiscountShown = ->
      self = sideOrder
      cartSvc.cart.total.upfrontSavings.value > 0

    # Whether to show the support credit used or not
    sideOrder.isCreditShown = ->
      self = sideOrder
      cartSvc.cart.total.supportCredit.value > 0

    # Whether to show the original payable amount or not
    sideOrder.isPayableShown = ->
      self = sideOrder
      self.isCreditShown() || self.isDiscountShown()

    # Whether to show the applicable tax and taxed
    # amount
    sideOrder.isTaxShown = ->
      ccDetails? && ccDetails.model? &&
      ccDetails.model.billing_country == 'AU' &&
      sideOrder.total('upfrontTax',{format: false}).value > 0

    sideOrder.isSavingsShown = ->
      self = sideOrder
      angular.isNumber(self.setting('reductionPercent')) && self.setting('reductionPercent') > 0

    sideOrder.labelForCheckoutBtn = ->
      if sideOrder.total('upfront',{format: false}).value > 0
        "Proceed and Pay"
      else
        "Proceed"

    # Return true if the user is under free trial
    # and order is free trial eligible
    sideOrder.isCoveredByFreeTrial = ->
      !sideOrder.isUpfrontPaymentRequired() && sideOrder.setting('underFreeTrial') && sideOrder.setting('freeTrialEligible')

    # Return true if the user is under free trial
    # and order is not free trial eligible
    sideOrder.isBeyondFreeTrial = ->
      !sideOrder.isUpfrontPaymentRequired() && sideOrder.setting('underFreeTrial') && !sideOrder.setting('freeTrialEligible')
    
    # Return true if the user is not under free trial and some
    # items require billing details to be entered
    sideOrder.isBillingDetailsRequired = ->
      !sideOrder.isUpfrontPaymentRequired() && !sideOrder.setting('underFreeTrial') && sideOrder.setting('creditCardRequired')
    
    # Return true if an upfront payment is required
    sideOrder.isUpfrontPaymentRequired = ->
      total = cartSvc.cart.total['upfront']
      return total.value > 0

    # Return true if the product ordered is a starter pack
    sideOrder.isStarterPack = ->
      cartSvc.cart.content.deal.product.match(/starter_pack/) ? true : false

    sideOrder.isLocked = ->
      cartSvc.data.fasttrack == 'locked' ? true : false      
    
    #=======================================================
    # Step: identifyUser
    #=======================================================
    modal.identifyUser = identifyUser = {}
    identifyUser.user = { $pwdScore: {} }

    # Display signup form by default
    identifyUser.initialize = ->
      identifyUser.switchToSignUp()

    # Check that the form is valid
    identifyUser.isNextDisabled = ->
      f = $scope.forms
      if modal.currentSubStep() == 'signin'
        return !angular.isObject(f.userSignin) || f.userSignin.$invalid
      else
        return !angular.isObject(f.userSignup) || f.userSignup.$invalid

    # Signin or signup the user
    # Parent method moves to the next step
    # only if response is successful
    identifyUser.next = ->
      self = identifyUser
      if modal.currentSubStep() == 'signin'
        self.signIn()
      else
        self.signUp()

    identifyUser.switchToSignIn = ->
      cartSvc.switchSubStepTo('signin')

    identifyUser.switchToSignUp = ->
      cartSvc.switchSubStepTo('signup')

    # Sign the user in
    # On success we flag the fact that the user
    # signed in during the process. If the popup gets
    # closed before checkout then the page gets reloaded
    # to make sure that the navbar reflects the fact that
    # the user is logged in
    identifyUser.signIn = ->
      self = identifyUser
      modal.setLoading("Signing in...")
      q = cartSvc.userSignIn(identifyUser.user['email'],identifyUser.user['password'])
      q.then(
        (success) ->
          modal.$signedInOrUpViaPopup = true
        ,(errors) ->
          modal.errors = Utilities.processRailsError(errors)
      ).finally(-> modal.setReady())
      return q

    # TODO: fix 406 unacceptable from devise
    # on user creation (still works)
    # On success we flag the fact that the user
    # signed up during the process. See 'signIn'
    # above for explanation
    identifyUser.signUp = ->
      self = identifyUser
      modal.setLoading("Creating your account...")
      q = cartSvc.userSignUp(identifyUser.user)
      q.then(
        (success) ->
          modal.$signedInOrUpViaPopup = true
        ,(errorData) ->
          modal.errors = Utilities.processRailsError({data: errorData.data.errors })
      ).finally(-> modal.setReady())
      return q


    #=======================================================
    # Step: selectOrga
    #=======================================================
    modal.selectOrga = selectOrga = {}
    selectOrga.organization = undefined
    selectOrga.organizations = []

    # Load the organizations the user has
    # access to
    selectOrga.initialize = ->
      self = selectOrga
      modal.setLoading()
      q = cartSvc.getOrganizations()
      q.then(
        (orgs) ->
          self.organizations = orgs
          if angular.isArray(orgs)
            # Prefer choosing the organization
            if (c = $scope.config()) && angular.isNumber(c.organizationId)
              self.organization = _.findWhere(orgs,{id: c.organizationId})

            if !self.organization? && orgs[0]?
              self.organization = orgs[0]

            if orgs.length == 1 && self.isUserAuthorized()
              modal.next()

          modal.setReady()

        ,(errors) ->
          modal.errors = Utilities.processRailsError(errors)
      )
      return q

    # Create the cart using the selected organization
    # Parent method moves to the next step
    # only if response is successful
    selectOrga.next = ->
      self = selectOrga
      cartSvc.createCart(self.organization)

    # Do not enable next button if user is not
    # authorized to purchase for the selected
    # organization
    selectOrga.isNextDisabled = ->
      !selectOrga.isUserAuthorized()

    # Check whether the user is authorized to purchase
    # for this organization
    selectOrga.isUserAuthorized = ->
      self = selectOrga
      !self.organization? || (_.contains(['Super Admin','Admin'],self.organization.role))


    #=======================================================
    # Step: chooseApps
    #=======================================================
    modal.chooseApps = chooseApps = {}
    chooseApps.apps = []

    # Load the apps
    # TODO: refactor last step which assigns the
    # temporary values from confirmed values
    chooseApps.initialize = ->
      self = chooseApps
      modal.setLoading()
      q = cartSvc.getApps()
      q.then(
        (apps) ->
          self.apps = apps
          modal.setReady()
          _.each self.appInstances(), (appInstance) ->
            self.cancelChange(appInstance)
        ,(errors) ->
          modal.errors = Utilities.processRailsError(errors)
      )
      return q

    # Nothing to do at this step
    chooseApps.next = ->
      q = $q.defer()
      q.resolve()
      return q.promise

    # Return all the apps that have
    # been added to the cart
    chooseApps.appInstances = ->
      cartSvc.cart.content.appInstances

    # Confirm a pending change on an application
    # by pushing the change to the remote cart
    chooseApps.confirmChange = (appInstance) ->
      self = chooseApps
      appInstance.app = appInstance.$app
      appInstance.size = appInstance.$size
      appInstance.billing = appInstance.$billing
      appInstance.country = appInstance.$country
      sideOrder.setLoading()
      cartSvc.upsertItem(appInstance).then ->
        self.cancelChange(appInstance)
        sideOrder.setReady()

    # TODO: move some internal logic to the
    # shopping cart service
    chooseApps.cancelChange = (appInstance) ->
      if angular.isNumber(appInstance.iid)
        appInstance.$app = appInstance.app
        appInstance.$size = appInstance.size
        appInstance.$billing = appInstance.billing
        appInstance.$country = appInstance.country
      else
        index = cartSvc.cart.content.appInstances.indexOf(appInstance)
        cartSvc.cart.content.appInstances.splice(index, 1)

    chooseApps.isDetailedPricingShown = (appInstance) ->
      appInstance.$app? && appInstance.$app.stack == 'cube'

    chooseApps.isCountryListShown = (appInstance) ->
      appInstance.$app? && appInstance.$app.nid == 'office-365'

    chooseApps.appUnchanged = (appInstance) ->
      appInstance.app == appInstance.$app &&
      appInstance.size == appInstance.$size &&
      appInstance.billing == appInstance.$billing &&
      appInstance.country == appInstance.$country

    # TODO: move some internal logic to the
    # shopping cart service
    chooseApps.addAppInstance = ->
      self = chooseApps
      defaultApp = self.apps[0]

      defaultSize = if self.apps[0].sizes then self.apps[0].sizes[0] else null

      appInstance = {
        entity: 'app_instance'
        $app: defaultApp
        $new: true
      }

      cartSvc.cart.content.appInstances ||= []
      cartSvc.cart.content.appInstances.push(appInstance)

      if angular.isArray(defaultApp.sizes)
         appInstance.$size = defaultApp.sizes[0]

      if angular.isArray(defaultApp.billings)
         appInstance.$billing = defaultApp.billings[0]

      if $scope.country_code
        appInstance.$country = $scope.country_code

    # Remove the provided app instance from the
    # cart
    chooseApps.removeAppInstance = (appInstance) ->
      self = chooseApps
      sideOrder.setLoading()
      cartSvc.removeItem(appInstance).then ->
        sideOrder.setReady()
      index = cartSvc.cart.content.appInstances.indexOf(appInstance)
      cartSvc.cart.content.appInstances.splice(index, 1)

    #=======================================================
    # Step: chooseDeal
    #=======================================================
    modal.chooseDeal = chooseDeal = {}
    chooseDeal.deal = null

    # Load the apps
    # nothing to do
    chooseDeal.initialize = ->
      null

    # If a deal has been selected then
    # the method adds it to the cart
    chooseDeal.next = ->
      self = chooseDeal
      q = $q.defer()
      if self.deal
        if self.cancelDeal
          cartSvc.removeItem(self.deal).then (data) ->
            self.deal = null
            q.resolve(data)
        else
          cartSvc.upsertItem(self.deal).then (data) ->
            q.resolve(data)
      else
        q.resolve()
      return q.promise

    # 3 deals available for the moment
    # - new_6_month_prepay
    # - new_12_month_prepay
    # - starter_pack_deal
    chooseDeal.selectDeal = (dealName)->
      self = chooseDeal
      self.deal = {
        entity: 'deal',
        product: dealName
      }
      modal.next()

    chooseDeal.skipDeal = ->
      chooseDeal.cancelDeal = true
      modal.next()

    #=======================================================
    # Step: chooseSupport
    #=======================================================
    modal.chooseSupport = chooseSupport = {}

    # TODO: should load the list of support items available
    # and inject it in scope for the accordion to display
    # automatically with a ng-repeat
    # Load the apps
    chooseSupport.initialize = ->
      null

    # If a support plan has been selected then
    # the method adds it to the cart
    chooseSupport.next = ->
      self = chooseSupport
      q = $q.defer()
      q.resolve()
      return q.promise

    chooseSupport.supportPlan = ->
      cartSvc.cart.content.support

    chooseSupport.isOwned = (planName) ->
      cartSvc.cart.setting.ownedSupportPlan == planName

    chooseSupport.isSelected = (planName) ->
      cartSvc.cart.content.support? &&
      cartSvc.cart.content.support.product == planName

    chooseSupport.statusFor = (planName) ->
      self = chooseSupport
      if self.isOwned(planName)
        return 'owned'
      else if self.isSelected(planName)
        return 'selected'
      return ''

    # WARNING: unrelevant copy/paste: should describe the plans...
    # Two deals available for the moment
    # - new_6_month_prepay
    # - new_12_month_prepay
    chooseSupport.selectPlan = (planName)->
      self = chooseSupport
      sideOrder.setLoading()
      supportPlan = { entity: 'support', product: planName }
      cartSvc.upsertItem(supportPlan).then (data) ->
        sideOrder.setReady()
      cartSvc.cart.content.support = supportPlan

    chooseSupport.removePlan = (planName) ->
      self = chooseSupport
      sideOrder.setLoading()
      if cartSvc.cart.content.support?
        cartSvc.removeItem(cartSvc.cart.content.support).then (data) ->
          sideOrder.setReady()
      cartSvc.cart.content.support = null

    #=======================================================
    # Step: chooseExtras
    #=======================================================
    modal.chooseExtras = chooseExtras = {}
    chooseExtras.selected = null
    chooseExtras.templates = [
      {
        entity: 'service',
        product: 'training',
        $label: 'Training (1h)',
        $price: '$150',
        $description: 'Get a one hour training session with one of our business success managers who will assist you in getting your business setup on Maestrano'
      },
      {
        entity: 'service',
        product: 'data_migration',
        $label: 'Data Migration',
        $price: '$500',
        $description: 'Want to boostrap your Maestrano applications with your business data? Save time and hire one of our data specialists to do it for you!'
      },
    ]

    # TODO: should load the list of extra items available
    # and inject it in scope for the accordion to display
    # automatically with a ng-repeat
    chooseExtras.initialize = ->
      null

    # Nothing to do at this step
    chooseExtras.next = ->
      q = $q.defer()
      q.resolve()
      return q.promise

    # Check whether an extra has been
    # added to the cart or not
    # TODO: move internal logic to the cart
    chooseExtras.isAdded = (extraTemplate) ->
      chooseExtras.findByTemplate(extraTemplate)?

    chooseExtras.findByTemplate = (extraTemplate) ->
      svcList = cartSvc.cart.content.services
      if angular.isArray(svcList)
        val = _.findWhere(svcList,{product: extraTemplate.product})
        return val
      return null

    # Add the extraTemplate to the shopping cart
    chooseExtras.add = (extraTemplate) ->
      item = angular.copy(extraTemplate)
      sideOrder.setLoading()
      cartSvc.cart.content.services ||= []
      cartSvc.cart.content.services.push(item)
      cartSvc.upsertItem(item).then ->
        sideOrder.setReady()

    # Remove the provided extra from the shopping
    # cart
    chooseExtras.remove = (extraTemplate) ->
      item = chooseExtras.findByTemplate(extraTemplate)
      sideOrder.setLoading()
      cartSvc.removeItem(item).then ->
        sideOrder.setReady()
      index = cartSvc.cart.content.services.indexOf(item)
      cartSvc.cart.content.services.splice(index, 1)

    #=======================================================
    # Step: orderSummary
    #=======================================================
    modal.orderSummary = orderSummary = {}

    orderSummary.initialize = ->
      null

    # If a credit card is required then
    # we move to the next step.
    # Otherwise we just perform the checkout
    orderSummary.next = ->
      q = $q.defer()
      modal.setLoading("Preparing your order...")
      if sideOrder.setting('creditCardRequired')
        q.resolve()
        modal.setReady()
      else
        sideOrder.checkout().then(
          (success) ->
            $scope.afterCheckoutAction()
          ,(errors) ->
            modal.errors = Utilities.processRailsError(errors)
        ).finally(-> modal.setReady())
      return q.promise

    #=======================================================
    # Step: ccDetails
    #=======================================================
    modal.ccDetails = ccDetails = {}
    ccDetails.model = {}
    ccDetails.config = {
      validTitles: ['Mr.', 'Ms.', 'Mrs.', 'Miss', 'Dr.', 'Sir.', 'Prof.']
      validMonths: [1..12]
      validYears: [d = (new Date).getFullYear()..d+20]
      validCountries: $window.Countries
    }

    # Load the beneficiary credit card from
    # the cart
    # If nil then we assign default value
    ccDetails.initialize = ->
      self = ccDetails
      angular.extend(self.model, cartSvc.cart.creditCard)
      unless angular.isObject(self.model) && angular.isNumber(self.model.id)
        _.each ['title','month','year','country','billing_country'], (attr) ->
          self.model[attr] = '--SELECT--'

    # Nothing to do at this step
    ccDetails.next = ->
      self = ccDetails
      modal.setLoading("Preparing your order...")
      q = sideOrder.checkout(self.model)
      q.then(
        (cart) ->
          if cart.pdfUrl?
            modal.setReady()
          else
            $scope.afterCheckoutAction()
        ,(errors) ->
          modal.setReady()
          modal.errors = Utilities.processRailsError(errors)
      )
      return q

    # Enable/Disable the credit card icons
    ccDetails.classForIconType = (ccType) ->
      self = ccDetails
      cType = self.getType()
      if ccType == self.getType() || cType == ""
        return "enabled"
      else
        return "disabled"

    # Return the credit card type (visa/mastercard/amex/jcb)
    ccDetails.getType = () ->
      self = ccDetails
      number = self.model.number
      if number != null && number != undefined
        re = new RegExp("^X");
        if (number.match(re) != null) then return ""

        re = new RegExp("^4");
        if (number.match(re) != null) then return "visa"

        re = new RegExp("^(34|37)");
        if (number.match(re) != null) then return "amex"

        re = new RegExp("^5[1-5]");
        if (number.match(re) != null) then return "mastercard"

        re = new RegExp("^6(?:011|5[0-9]{2})");
        if (number.match(re) != null) then return "discover"

        re = new RegExp("(?:2131|1800|35[0-9]{3})")
        if (number.match(re) != null) then return "jcb"

        re = new RegExp("^3(?:0[0-5]|[68][0-9])")
        if (number.match(re) != null) then return "dinersclub"

        # Last resort we assume that it is a Mastercard if
        # the number is long enough
        # See:
        #http://stackoverflow.com/questions/72768/how-do-you-detect-credit-card-type-based-on-number
        if number.length > 4
          return "mastercard"
        else
          return ""

      return ""

    #=======================================================
    # Step: confirmScreen
    #=======================================================
    modal.confirmScreen = confirmScreen = {}
    confirmScreen.pdfUrl = null

    # Load the beneficiary credit card from
    # the cart
    # If nil then we assign default value
    confirmScreen.initialize = ->
      null

    # Nothing to do at this step
    confirmScreen.next = ->
      self = ccDetails
      q = $q.defer()
      q.resolve()
      $scope.afterCheckoutAction()
      return q
      
    confirmScreen.pdfUrl = ->
      cartSvc.cart.pdfUrl

    confirmScreen.isInvoiceAvailable = ->
      confirmScreen.pdfUrl?

    confirmScreen.finish = ->
      $scope.afterCheckoutAction()

    confirmScreen.isStarterPack = ->
      sideOrder.isStarterPack()

    confirmScreen.total = ->
      cartSvc.cart.total['upfrontWithTax'].value

    confirmScreen.userId = ->
      cartSvc.cart.id

    #=======================================================
    # Initialization
    #=======================================================
    # Watch the change of value for mnoShoppingCart
    $scope.$watch(
      (-> $scope.mnoShoppingCart),
      (newVal,oldVal) ->
        if newVal && newVal != oldVal
          $scope.modal.open()
    )

    # Open shopping cart straight away if mnoShoppingCart
    # is initialized with true on page load
    $scope.modal.open() if $scope.mnoShoppingCart

])

module.directive('mnoShoppingCart', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A',
      scope: {
        bundle: '&',
        mnoShoppingCart: '='
        config: '&'
      },
      controller: 'MnoShoppingCartCtrl',
  }
])
