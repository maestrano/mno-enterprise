angular.module('maestrano.services.current-user-svc', []).factory('CurrentUserSvc', ['$http', ($http) ->
  service = {}
  
  # Configuration
  service.config = {
    signInPath: '/mnoe/auth/users/sign_in'
    signUpPath: '/mnoe/auth/users'
    updatePath: '/mnoe/jpi/v1/current_user',
    updatePasswordPath: '/mnoe/jpi/v1/current_user/update_password',
  }
  
  # Load User
  service.then = (fn = nil) ->
    service.loadDocument().then(fn)
    
  service.loadDocument = (force = false)->
    self = service
    if self.document == undefined || force
      self.query = $http.get("/mnoe/jpi/v1/current_user")
      self.query.success (data) ->
        self.document = data
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
  
  service.update = (data) ->
    self = service
    return $http.put(self.config.updatePath,{user:data}).then (resp) ->
      userResp = resp.data.current_user
      angular.copy(userResp, self.document.current_user)
      return userResp
  
  service.updatePassword = (newPassword,confirmPassword,currentPassword) ->
    self = service
    return $http.put(self.config.updatePasswordPath,{ user: {
      password: newPassword,
      password_confirmation: confirmPassword,
      current_password: currentPassword
    } })
  
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

  service.getSsoSessionId = ->
    self = service
    if self.document?
      return self.document.current_user.sso_session
    else
      return null  
  
  return service

])
