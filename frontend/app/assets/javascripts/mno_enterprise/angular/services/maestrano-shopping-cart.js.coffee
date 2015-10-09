#
# Main Shopping cart steps
# 0) start
# 1) identifyUser
# 2) selectOrga (optional)
# 3) chooseApps
# 4) chooseDeal (optional)
# 5) chooseSupport
# 6) chooseExtras
# 7) orderSummary
# 8) paymentScreen (optional)
# 9) checkout
# 10) confirmScreen (optional)
# 
angular.module('maestrano.services.shopping-cart', [])
.factory('ShoppingCart', ['$http','$q','CurrentUserSvc', ($http,$q,$CurrentUserSvc) ->
  service = {}
  service.config = {
    allAppsPath: '/mnoe/jpi/v1/shopping_cart/apps',
    allOrgsPath: '/mnoe/jpi/v1/shopping_cart/organizations'
    cartRootPath: '/mnoe/jpi/v1/shopping_cart'
    
    deals: [{ entity: 'deal', product: 'new_6_month_prepay'},
    { entity: 'deal', product: 'new_12_month_prepay'},
    { entity: 'deal', product: 'starter_pack_deal'}]
    
    firstStep: 'identifyUser'
    steps: {
      identifyUser: {
        number: 0
        skipCondition: ( (svc)-> svc.data.user? && svc.data.user.email? &&  svc.data.user.email != '') 
        next: 'selectOrga'
        showOrder: false
        showFunnel: false
      },
      selectOrga: {
        number: 0
        skipCondition: ( (svc)-> svc.data.organization? )
        next: 'chooseApps'
        showOrder: false
        showFunnel: false
      },
      chooseApps: {
        number: 1
        skipCondition: ( (svc)-> svc.data.fasttrack )
        next: 'chooseDeal'
        showOrder: true
        showFunnel: true
        orderMode: 'list'
      },
      chooseDeal: {
        number: 2
        skipCondition: ( (svc)-> svc.data.fasttrack || !svc.isDealProposed() )
        next: 'chooseSupport'
        showOrder: true
        showFunnel: true
        orderMode: 'list'
      },
      chooseSupport: {
        number: 2
        skipCondition: ( (svc)-> svc.data.fasttrack )
        next: 'chooseExtras'
        showOrder: true
        showFunnel: true
        orderMode: 'list'
      },
      chooseExtras: {
        number: 3
        skipCondition: ( (svc)-> svc.data.fasttrack )
        next: 'orderSummary'
        showOrder: true
        showFunnel: true
        orderMode: 'list'
      },
      orderSummary: {
        number: 4
        next: 'ccDetails'
        showOrder: true
        showFunnel: true
        orderMode: 'summary'
      },
      ccDetails: {
        number: 4
        next: 'confirmScreen'
        showOrder: true
        showFunnel: true
        orderMode: 'summary'
      },
      confirmScreen: {
        number: 4
        showOrder: false
        showFunnel: false
      },
      
    }
  }
  
  
  #==========================================
  # Workflow functions
  #==========================================
  service.setLoading = (val)->
    service.state.loading = val
  
  # Switch the cart to a new step
  service.switchStepTo = (stepName) ->
    self = service
    self.state.stepHist.push(self.state.step)
    self.state.subStep = null
    self.state.step = stepName
  
  service.switchSubStepTo = (subStepName) ->
    self = service
    self.state.subStep = subStepName
  
  # Move the cart workflow to the next
  # step
  # Passing is a step in argument is optional
  # and only used by the next method itself
  # when it need to skip steps (recursive call)
  service.next = (currStep = null)->
    self = service
    
    # We get the next step to target
    currentStep = (currStep || self.state.step)
    if currentStep
      nextStep = self.config.steps[currentStep]['next']
    else
      nextStep = self.config.firstStep
    
    # Exit if no next step
    unless nextStep?
      return null
    
    # Check if we can skip it
    if angular.isFunction(self.config.steps[nextStep]['skipCondition'])
      if self.config.steps[nextStep]['skipCondition'](self)
        return self.next(nextStep)
    
    # Switch to the nextStep
    self.switchStepTo(nextStep)
  
  # Go back one step
  service.back = ()->
    self = service
    self.state.step = self.state.stepHist.pop()
    return self.state.step
  
  #==========================================
  # HTTP functions
  #==========================================
  service.addBundle = (bundle = null)->
    self = service
    return false unless angular.isObject(bundle)
    
    # Register bundle
    self.$bundle = bundle
    
    # Check if we should fasttrack
    self.data.fasttrack = self.$bundle.fasttrack || false
  
  # Retrieve the list of available applications to purchase
  # Also add any app from the provided bundle that is not
  # in the list of available apps (useful to display sandbox apps or non-active
  # apps properly when they are specifically chosen)
  service.getApps = ()->
    self = service
    return self.$q['apps'] if self.$q['apps']
    
    # If a bundle is present, pass the apps as parameter to ensure
    # they are in the returned list
    # Need to pass app_instances as JSON as $http.get 'params' doe not handle
    # automated conversion of JS objects
    config = {}
    config['params'] = { ensure_apps: angular.toJson(self.$bundle.app_instances) } if self.$bundle
    
    # Fetch the apps
    path = self.config.allAppsPath
    self.$q['apps'] = $http.get(path,config).then((result)-> self.data.apps = result['data'])
    
    # Return the promise
    self.$q['apps']
  
  service.getOrganizations = () ->
    self = service
    unless self.$q['organizations']
      path = self.config.allOrgsPath
      self.$q['organizations'] = $http.get(path).then((result)-> self.data.organizations = result['data'])
    self.$q['organizations']
  
  # Load details about the current user
  service.getUser = () ->
    self = service
    $CurrentUserSvc.loadDocument().then(
      (result) ->
        self.data.user = result['data']['user']
    )
  
  # Call user service and log the current
  # user in
  service.userSignIn = (email,password) ->
    self = service
    $CurrentUserSvc.signIn(email,password)
      .then((user) -> self.data.user = user)
  
  # Call user service and sign the current
  # user up
  service.userSignUp = (hash) ->
    self = service
    $CurrentUserSvc.signUp(hash)
      .then((user) -> self.data.user = user)
  
  # Remotely push an item to the cart, update
  # the item locally with the response as well
  # as the financials
  # TODO: id should actually be generated
  # on the backend side
  service.upsertItem = (hash) ->
    self = service
    path = "#{self.config.cartRootPath}/#{self.cart.id}/upsert_item"
    $http.put(path,{ item: hash }).then(
      (result) ->
        angular.extend(hash,result.data.item)
        angular.extend(self.cart, result.data.cart)
    )
  
  # Remotely remove an item from the cart and
  # update the totals
  service.removeItem = (hash) ->
    self = service
    path = "#{self.config.cartRootPath}/#{self.cart.id}/remove_item"
    $http.put(path,{ item: hash }).then(
      (result) ->
        angular.extend(self.cart, result.data.cart)
    )
  
  # Generate an item id for a new item
  # Used for item edition
  # TODO: refactor - remove harcoded offset
  service.generateItemId = ->
    self = service
    self.state.itemIdCounter += 1
    id = self.state.itemIdCounter
    id += 1000
    if self.cart? && angular.isNumber(self.cart.lastItemId)
      id += self.cart.lastItemId
    id.toString()
  
  # Create a new cart using the current
  # cart user and provided organization
  service.createCart = (orga)->
    self = service
    path = self.config.cartRootPath
    data = { shopping_cart: { organization_id: orga.id, bundle: self.$bundle } }
    $http.post(path,data).then (result) ->
      self.data.organization = orga
      self.cart = result['data']
  
  service.checkout = (creditCard = {})->
    self = service
    path = "#{self.config.cartRootPath}/#{self.cart.id}/checkout"
    $http.put(path,{ credit_card:  creditCard}).then(
      (result) ->
        angular.extend(self.cart, result.data)
    )
    
  
  #==========================================
  # Step specific methods
  #==========================================
  # Check whether we should display the deal page
  # or not
  service.isDealProposed = ()->
    hasHostedApp = _.findWhere(service.cart.content.appInstances, { product: 'cube'})?
    createdAt = moment(service.data.user.createdAt)
    hasHostedApp && createdAt > moment().subtract({days:1})
  
  # Should we show the order summary at the current
  # step
  service.isOrderShown = ->
    self = service
    self.config.steps[self.state.step]? && self.config.steps[self.state.step].showOrder
  
  # Should we show the funnel for the current
  # step
  service.isFunnelShown = ->
    self = service
    self.config.steps[self.state.step]? && self.config.steps[self.state.step].showFunnel
  
  service.stepNumber = ->
    self = service
    self.config.steps[self.state.step]? && self.config.steps[self.state.step].number
  
  # Should the side area be a list or summary?
  service.sideAreaMode = ->
    self = service
    self.config.steps[self.state.step]? && self.config.steps[self.state.step].orderMode
  
  service.isPartnerFieldShown = ->
    service.isDealProposed()
  
  #==========================================
  # Main functions
  #==========================================
  # Reset the cart service internal data
  service.initialize = ()->
    service.$bundle = {}
    service.$q = {}
    service.data = {
      apps: [],
      organizations: null,
      user: null
      fasttrack: false
    }
    service.cart = {
      id: null
      lastItemId: 0
      content: {
        appInstances: {}
        services: {}
        support: null
        deal: null
      }
      total: {}
      orderList: {
        hourly: []
        monthly: []
        adhoc: []
        variable: []
      }
    }
    service.state = {
      subStep: null
      step: null
      stepHist: []
      loading: false
      totalsLoading: false
      itemIdCounter: 0
    }
    
  # Initialize a new shopping cart workflow
  service.start = (bundle = null)->
    self = service
    # Reset the service
    self.initialize()
    
    # Process the bundle
    self.addBundle(bundle)
    
    # Load the apps in the background
    self.getApps()
    
    # Get the user info
    self.getUser().then ->
      # Move to the next step
      self.next()
  
  
  
  return service
])
