module = angular.module('maestrano.dashboard.dashboard-organization-members',['maestrano.assets'])

#============================================
#
#============================================
module.controller('DashboardOrganizationMembersCtrl',[
  '$scope','$window','DhbOrganizationSvc','DhbTeamSvc', 'Utilities','AssetPath','$modal', '$q',
  ($scope, $window, DhbOrganizationSvc, DhbTeamSvc, Utilities, AssetPath,$modal, $q) ->
    #====================================
    # Pre-Initialization
    #====================================
    $scope.assetPath = AssetPath
    $scope.isLoading = true
    $scope.members = []
    $scope.teams = []
    
    #====================================
    # Scope Management
    #====================================
    # Initialize the data used by the directive
    $scope.initialize = (members, teams = nil) ->
      angular.copy(members,$scope.members)
      angular.copy(teams,$scope.teams) if teams
      $scope.isLoading = false
    
    $scope.editMember = (member) ->
      $scope.editionModal.open(member)
    
    $scope.removeMember = (member) ->
      $scope.deletionModal.open(member)
    
    $scope.inviteMembers = ->
      $scope.inviteModal.open()
    
    $scope.isInviteShown = ->
      DhbOrganizationSvc.can.create.member()
    
    $scope.isEditShown = (member) ->
      DhbOrganizationSvc.can.update.member(member)
    
    $scope.isRemoveShown = (member) ->
      DhbOrganizationSvc.can.destroy.member(member)
    
    $scope.memberRoleLabel = (member) ->
      if member.entity == 'User'
        return member.role
      else
        return "Invited (#{member.role})"
    
    #====================================
    # User Edition Modal
    #====================================
    $scope.editionModal = editionModal = {}
    editionModal.config = {
      instance: {
        backdrop: 'static'
        templateUrl: 'dashboard/organization/members/edition-modal.html'
        size: 'lg'
        windowClass: 'inverse member-edit'
        scope: $scope
      }
      roles: ['Member','Power User','Admin','Super Admin']
    }
    
    editionModal.open = (member) ->
      self = editionModal
      self.member = member
      self.selectedRole = member.role
      self.$instance = $modal.open(self.config.instance)
      self.isLoading = false
      editionModal.member = member
    
    editionModal.title = ->
      m = editionModal.member
      if m.entity == 'User'
        return "Edit Member: #{m.name} #{m.surname}"
      else
        return "Edit Member: #{m.email}"
    
    editionModal.close = ->
      self = editionModal
      self.$instance.close()
    
    editionModal.select = (role) ->
      editionModal.selectedRole = role
    
    editionModal.classForRole = (role) ->
      self = editionModal
      if role == self.member.role
        return 'btn-info'
      else if role == self.selectedRole
        return 'btn-warning'
      else
        return ''
    
    editionModal.isChangeDisabled = ->
      editionModal.member.role == editionModal.selectedRole
    
    editionModal.change = ->
      self = editionModal
      self.isLoading = true
      obj = { email: self.member.email, role: self.selectedRole }
      DhbOrganizationSvc.members.update(obj).then(
        (members) ->
          self.errors = ''
          angular.copy(members,$scope.members)
          self.close()
        , (errors) ->
          self.errors = Utilities.processRailsError(errors)
      ).finally(-> self.isLoading = false)
    
    #====================================
    # User Deletion Modal
    #====================================
    $scope.deletionModal = deletionModal = {}
    deletionModal.config = {
      instance: {
        backdrop: 'static'
        templateUrl: 'dashboard/organization/members/removal-modal.html'
        size: 'lg'
        windowClass: 'inverse member-edit'
        scope: $scope
      }
    }
    
    deletionModal.open = (member) ->
      self = deletionModal
      self.member = member
      self.$instance = $modal.open(self.config.instance)
      self.isLoading = false
      self.member = member
    
    deletionModal.close = ->
      self = deletionModal
      self.$instance.close()
    
    deletionModal.confirmationText = ->
      m = deletionModal.member
      if m.entity == 'User' && m.name?
        return "Do you really want to remove <strong>#{m.name} #{m.surname}</strong> from your company?"
      else
        return "Do you really want to remove <strong>#{m.email}</strong> from your company?"
    
    deletionModal.remove = ->
      self = deletionModal
      self.isLoading = true
      obj = { email: self.member.email }
      DhbOrganizationSvc.members.remove(obj).then(
        (members) ->
          self.errors = ''
          angular.copy(members,$scope.members)
          self.close()
        , (errors) ->
          self.errors = Utilities.processRailsError(errors)
      ).finally(-> self.isLoading = false)  
    
    #====================================
    # Invite Modal
    #====================================
    $scope.inviteModal = inviteModal = {}
    inviteModal.config = {
      instance: {
        backdrop: 'static'
        templateUrl: 'dashboard/organization/members/invite-modal.html'
        size: 'lg'
        windowClass: 'inverse member-edit'
        scope: $scope
      }
      defaultRole: 'Member'
      roles: ->
        list = ['Member','Power User','Admin']
        list.push('Super Admin') if DhbOrganizationSvc.user.isSuperAdmin()
        return list
      teams: ->
        $scope.teams
    }
    
    inviteModal.open = () ->
      self = inviteModal
      self.$instance = $modal.open(self.config.instance)
      self.isLoading = false
      self.members = []
      self.userEmails = ''
      self.step = 'enterEmails'
      self.roleList = self.config.roles()
      self.teamList = self.config.teams()
      self.invalidEmails = []
    
    inviteModal.close = ->
      self = inviteModal
      self.$instance.close()
    
    inviteModal.isTeamListShown = ->
      inviteModal.teamList.length > 0
    
    inviteModal.title = ->
      self = inviteModal
      if self.step == 'enterEmails'
        "Enter email addresses"
      else
        "Select role for each new member"
    
    inviteModal.labelForAction = ->
      if inviteModal.step == 'enterEmails'
        return "Next"
      else
        return "Invite"
    
    inviteModal.next = ->
      self = inviteModal
      if self.step == 'enterEmails'
        inviteModal.processEmails()

      else
        inviteModal.inviteMembers()
    
    inviteModal.isNextEnabled = ->
      self = inviteModal
      self.step == 'defineRoles' || (self.step == 'enterEmails' && self.userEmails.length > 0)

    inviteModal.oneValidEmail = ->
      self = inviteModal
      res = false
      _.each self.userEmails.split("\n"), (email) ->

        res = true if email.match(email_regexp)
      return res

    inviteModal.processEmails = ->
      self = inviteModal
      self.isLoading = true
      self.members = []
      self.invalidEmails = []

      _.each self.userEmails.split("\n"), (email) ->
        email_regexp = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
        if email.match(email_regexp)
          self.members.push({email: email, role: self.config.defaultRole })
        else
          self.invalidEmails.push(email)

      self.isLoading = false
      if self.invalidEmails.length == 0
        self.step = 'defineRoles'

    inviteModal.inviteMembers = ->
      self = inviteModal
      self.isLoading = true
      DhbOrganizationSvc.members.invite(self.members).then(
        (members) ->
          self.errors = ''
          angular.copy(members,$scope.members)
          self.close()
        , (errors) ->
          self.errors = Utilities.processRailsError(errors)
      ).finally(-> self.isLoading = false)
    
    
    #====================================
    # Post-Initialization
    #====================================
    refresh = ->
      $q.all([DhbOrganizationSvc.load(),DhbTeamSvc.load()]).then (values)->
        $scope.initialize(values[0].organization.members,values[1])
    
    contextObj = ->
      { orgId: DhbOrganizationSvc.getId(), teams: DhbTeamSvc.data }
      
    $scope.$watch contextObj, refresh, true
])

module.directive('dashboardOrganizationMembers', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A',
      scope: {
      },
      templateUrl: TemplatePath['mno_enterprise/dashboard/organization/members.html'],
      controller: 'DashboardOrganizationMembersCtrl'
    }
])
