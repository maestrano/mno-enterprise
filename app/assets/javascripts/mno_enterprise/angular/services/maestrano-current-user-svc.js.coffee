angular.module('maestrano.services.current-user-svc', []).factory('CurrentUserSvc', ['$http', ($http) ->
  service = {}
  
  # Configuration
  service.config = {
    signInPath: '/mnoe/auth/users/sign_in'
    signUpPath: '/mnoe/auth/users'
  }
  
  # Load User
  service.then = () ->
  service.loadDocument = (force = false)->
    self = service
    if self.document == undefined || force
      self.query = $http.get("/mnoe/jpi/v1/current_user")
      self.then = self.query.then
      self.query.success (data) ->
        self.document = data
    else
      return self.query

  
  # Sign user in
  # Return a promise
  service.signIn = (email,password) ->
    self = service
    creds = {email: email, password: password}
    $http.post(self.config.signInPath,{user: creds})
      .then(-> self.loadDocument(true))

  service.addOrg = (org) ->
    self = service
    if self.document && self.document.current_user && self.document.current_user.organizations
      self.document.current_user.organizations.push(org)
  
  # Sign user up
  # expect the following hash:
  # {
  #   name: 'John',
  #   surname: 'Doe',
  #   email: 'john.doe@doecorp.com',
  #   password: 'jdoedoe',
  #   password_confirmation: 'jdoejdoe'
  # }
  # Return a promise
  service.signUp = (hash) ->
    self = service
    $http.post(self.config.signUpPath,{user: hash})
      .then(-> self.loadDocument(true))
  
  return service

])
