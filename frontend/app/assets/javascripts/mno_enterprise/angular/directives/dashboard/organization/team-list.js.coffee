module = angular.module('maestrano.dashboard.dashboard-organization-team-list',['maestrano.assets'])

#============================================
#
#============================================
module.controller('DashboardOrganizationTeamListCtrl',[
  '$scope','$window','DhbOrganizationSvc', 'DhbTeamSvc', 'Utilities','AssetPath','$modal','TemplatePath','$q',
  ($scope, $window, DhbOrganizationSvc, DhbTeamSvc, Utilities, AssetPath,$modal,TemplatePath,$q) ->
    #====================================
    # Pre-Initialization
    #====================================
    $scope.assetPath = AssetPath
    $scope.isLoading = true
    $scope.teams = []
    
    #====================================
    # Scope Management
    #====================================
    # Initialize the data used by the directive
    # If the current user is not a manager then
    # the directive restricts the list to the current
    # user's teams only
    $scope.initialize = (teams) ->
      realTeams = []
      if $scope.canManageTeam()
        realTeams = teams
      else
        _.each teams, (t) ->
          realTeams.push(t) if $scope.teamHasUser(t,DhbOrganizationSvc.data.current_user)
      
      angular.copy(realTeams,$scope.teams)
      $scope.isLoading = false
    
    $scope.isTeamEmpty = (team) ->
      team.users.length == 0
    
    $scope.hasTeams = ->
      $scope.teams.length > 0
    
    $scope.canManageTeam = ->
      DhbOrganizationSvc.can.create.member()
    
    $scope.teamHasUser = (team,user) ->
      _.find(team.users,(u)-> u.id == user.id)?
    
    #====================================
    # Team: Member Add Modal
    #====================================
    $scope.memberAddModal = memberAddModal = {}
    memberAddModal.config = {
      instance: {
        backdrop: 'static'
        templateUrl: TemplatePath['mno_enterprise/dashboard/teams/member-add-modal.html']
        size: 'lg'
        windowClass: 'inverse team-member-add-modal'
        scope: $scope
      }
    }
    
    memberAddModal.open = (team) ->
      self = memberAddModal
      self.team = team
      self.users = []
      self.userList = self.getAvailableUsers(team)
      self.$instance = $modal.open(self.config.instance)
      self.isLoading = false
    
    memberAddModal.close = ->
      self = memberAddModal
      self.$instance.close()
    
    memberAddModal.getAvailableUsers = (team) ->
      self = memberAddModal
      list = []
      _.each DhbOrganizationSvc.data.organization.members, (m) ->
        unless _.find(team.users,(u)-> u.id == m.id)?
          list.push(m) if m.entity == 'User'
      return list
    
    memberAddModal.canAddUsers = ->
       self = memberAddModal
       self.userList.length > 0
       
    memberAddModal.hasUser = (user) ->
      self = memberAddModal
      _.contains(self.users,user)
    
    memberAddModal.toggleUser = (user) ->
      self = memberAddModal
      if self.hasUser(user)
        self.removeUser(user)
      else
        self.addUser(user)
    
    memberAddModal.addUser = (user) ->
      self = memberAddModal
      unless self.hasUser(user)
        self.users.push(user)
    
    memberAddModal.removeUser = (user) ->
      self = memberAddModal
      if (idx = self.users.indexOf(user)) >= 0
        self.users.splice(idx,1)
    
    memberAddModal.proceed = ->
      self = memberAddModal
      self.isLoading = true
      DhbTeamSvc.members.add(self.team.id,self.users).then(
        (users) ->
          self.errors = ''
          angular.copy(users,self.team.users)
          self.close()
        , (errors) ->
          self.errors = Utilities.processRailsError(errors)
      ).finally(-> self.isLoading = false)
    
    #====================================
    # Team: Member Removal Modal
    #====================================
    $scope.memberRemovalModal = memberRemovalModal = {}
    memberRemovalModal.config = {
      instance: {
        backdrop: 'static'
        templateUrl: TemplatePath['mno_enterprise/dashboard/teams/member-removal-modal.html']
        size: 'lg'
        windowClass: 'inverse team-member-removal-modal'
        scope: $scope
      }
    }
    
    memberRemovalModal.open = (team,user) ->
      self = memberRemovalModal
      self.team = team
      self.user = user
      self.$instance = $modal.open(self.config.instance)
      self.isLoading = false
    
    memberRemovalModal.close = ->
      self = memberRemovalModal
      self.$instance.close()
    
    memberRemovalModal.proceed = ->
      self = memberRemovalModal
      self.isLoading = true
      DhbTeamSvc.members.remove(self.team.id,[self.user]).then(
        (users) ->
          self.errors = ''
          angular.copy(users,self.team.users)
          self.close()
        , (errors) ->
          self.errors = Utilities.processRailsError(errors)
      ).finally(-> self.isLoading = false)
    
    #====================================
    # Post-Initialization
    #====================================
    refresh = ->
      $q.all([DhbOrganizationSvc.load(),DhbTeamSvc.load()]).then (values)->
        $scope.initialize(values[1])
    
    contextObj = ->
      { orgId: DhbOrganizationSvc.getId(), teams: DhbTeamSvc.data}
    
    # Combined Watch 
    # reload on org id change and team change
    $scope.$watch contextObj, refresh, true
        
])

module.directive('dashboardOrganizationTeamList', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A',
      scope: {
        title: '@'
      },
      templateUrl: TemplatePath['mno_enterprise/dashboard/teams/team-list.html'],
      controller: 'DashboardOrganizationTeamListCtrl'
    }
])