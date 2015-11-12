#
# Mnoe Users List
#
@App.directive('mnoeUsersList', ($filter, LIST_STATE) ->
  restrict: 'E'
  scope: {
    list: '='
  },
  templateUrl: 'app/components/mnoe-users-list/mno-users-list.html',
  link: (scope) ->
    scope.LIST_STATE = LIST_STATE

    # Variables initialization
    scope.users =
      displayList: []
      search: ''
      state: LIST_STATE.last10

    setLastUsersList = () ->
      scope.users.state = LIST_STATE.last10
      scope.users.displayList = $filter('orderBy')(scope.list, '-created_at')
      scope.users.displayList = $filter('limitTo')(scope.users.displayList, 10)

    setSearchUsersList = (ro) ->
      scope.users.state = LIST_STATE.search
      searchToLowerCase = scope.users.search.toLowerCase()
      scope.users.displayList = _.filter(scope.list, (user) ->
        email = _.startsWith(user.email.toLowerCase(), searchToLowerCase)
        name = _.startsWith(user.name.toLowerCase(), searchToLowerCase)
        surname = _.startsWith(user.surname.toLowerCase(), searchToLowerCase)
        (email || name || surname)
      )
      scope.users.displayList = $filter('orderBy')(scope.users.displayList, 'email')

    scope.searchChange = () ->
      if scope.users.search == ''
        setLastUsersList()
      else
        setSearchUsersList()

    scope.$watch('list', (newVals, oldVals) ->
      console.log newVals, oldVals
      setLastUsersList()
    , true)
)
