#
# Mnoe Users List
#
@App.directive('mnoeUsersLocalList', ($window, $filter, $log, toastr, MnoeUsers, MnoErrorsHandler) ->
  restrict: 'E'
  scope: {
    list: '='
    organization: '='
  },
  templateUrl: 'app/components/mnoe-users-local-list/mnoe-users-local-list.html',
  link: (scope, elem, attrs) ->

    # Variables initialization
    scope.users =
      displayList: []
      widgetTitle: 'Loading users...'
      search: ''

    # Display all the users
    setAllUsersList = () ->
      scope.users.widgetTitle = 'All users (' + scope.list.length + ')'
      scope.users.switchLinkTitle = '(last 10)'
      scope.users.displayList = $filter('orderBy')(scope.list, 'email')

    # Display only the last 10 users
    setLastUsersList = () ->
      scope.users.widgetTitle = 'Last 10 users'
      scope.users.switchLinkTitle = '(view all)'
      scope.users.displayList = $filter('orderBy')(scope.list, '-created_at')
      scope.users.displayList = $filter('limitTo')(scope.users.displayList, 10)

    # Display only the search results
    setSearchUsersList = () ->
      scope.users.widgetTitle = 'Search result'
      delete scope.users.switchLinkTitle
      searchToLowerCase = scope.users.search.toLowerCase()
      scope.users.displayList = _.filter(scope.list, (user) ->
        email = _.contains(user.email.toLowerCase(), searchToLowerCase) if user.email
        name = _.contains(user.name.toLowerCase(), searchToLowerCase) if user.name
        surname = _.contains(user.surname.toLowerCase(), searchToLowerCase) if user.surname
        (email || name || surname)
      )
      scope.users.displayList = $filter('orderBy')(scope.users.displayList, 'email')

    displayNormalState = () ->
      # if view="all" is set on the directive, all the users are displayed
      # if view="last" is set on the directive, the last 10 users are displayed
      if attrs.view == 'all'
        setAllUsersList()
      else if attrs.view == 'last'
        setLastUsersList()
      else
        $log.error('Value of attribute view can only be "all" or "last"')

    scope.switchState = () ->
      if attrs.view == 'all'
        attrs.view = 'last'
      else
        attrs.view = 'all'
      displayNormalState()

    scope.searchChange = () ->
      if scope.users.search == ''
        displayNormalState()
      else
        setSearchUsersList()

    # Send an invitation to a user
    scope.sendInvitation = (user) ->
      user.isSendingInvite = true
      MnoeUsers.inviteUser(scope.organization, user).then(
        (response) ->
          toastr.success("#{user.name} #{user.surname}'s invitation has been sent.")
          # Update status
          user.status = response.data.user.status
        (error) ->
          toastr.error("An error occurred: #{user.name} #{user.surname}'s invitation has not been sent.")
          MnoErrorsHandler.processServerError(error)
      ).finally(-> user.isSendingInvite = false)

    # Impersonate the user
    scope.impersonateUser = (user) ->
      if user
        redirect = window.encodeURIComponent("#{location.pathname}#{location.hash}")
        url = "/mnoe/impersonate/user/#{user.id}?redirect_path=#{redirect}"
        $window.location.href = url

    scope.$watch('list', (newVal) ->
      if newVal
        displayNormalState()
    , true)
)
