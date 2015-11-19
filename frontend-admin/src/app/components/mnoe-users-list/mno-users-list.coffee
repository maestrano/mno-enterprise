#
# Mnoe Users List
#
@App.directive('mnoeUsersList', ($filter) ->
  restrict: 'E'
  scope: {
    list: '='
  },
  templateUrl: 'app/components/mnoe-users-list/mno-users-list.html',
  link: (scope, elem, attrs) ->

    # Variables initialization
    scope.users =
      displayList: []
      widgetTitle: 'Loading users...'
      search: ''

    # Display all the users
    setAllUsersList = () ->
      scope.users.widgetTitle = 'All users (' + scope.list.length + ')'
      scope.users.displayList = $filter('orderBy')(scope.list, 'email')
      scope.users.displayList = $filter('limitTo')(scope.users.displayList, 10)

    # Display only the last 10 users
    setLastUsersList = () ->
      scope.users.widgetTitle = 'Last 10 users'
      scope.users.displayList = $filter('orderBy')(scope.list, '-created_at')

    # Display only the search results
    setSearchUsersList = () ->
      scope.users.widgetTitle = 'Search result'
      searchToLowerCase = scope.users.search.toLowerCase()
      scope.users.displayList = _.filter(scope.list, (user) ->
        email = _.contains(user.email.toLowerCase(), searchToLowerCase) if user.email
        name = _.contains(user.name.toLowerCase(), searchToLowerCase) if user.name
        surname = _.contains(user.surname.toLowerCase(), searchToLowerCase) if user.surname
        (email || name || surname)
      )
      scope.users.displayList = $filter('orderBy')(scope.users.displayList, 'email')

    displayNormalState = () ->
      # if all="true" is set on the directive, all the users are displayed
      if attrs.all == 'true'
        setAllUsersList()
      else
        setLastUsersList()

    scope.searchChange = () ->
      if scope.users.search == ''
        displayNormalState()
      else
        setSearchUsersList()

    scope.$watch('list', (newVal, oldVal) ->
      if newVal
        displayNormalState()
    , true)
)
