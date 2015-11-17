#
# Mnoe organizations List
#
@App.directive('mnoeOrganizationsList', ($filter) ->
  restrict: 'E'
  scope: {
    list: '='
  },
  templateUrl: 'app/components/mnoe-organizations-list/mnoe-organizations-list.html',
  link: (scope) ->
    # Variables initialization
    scope.organizations =
      displayList: []
      widgetTitle: 'Last 10 users'
      search: ''

    setLastOrganizationsList = () ->
      scope.organizations.widgetTitle = 'Last 10 organisations'
      scope.organizations.displayList = $filter('orderBy')(scope.list, '-created_at')
      scope.organizations.displayList = $filter('limitTo')(scope.organizations.displayList, 10)

    setSearchOrganizationsList = () ->
      scope.organizations.widgetTitle = 'Search result'
      searchToLowerCase = scope.organizations.search.toLowerCase()
      scope.organizations.displayList = _.filter(scope.list, (org) ->
        name = _.contains(org.name.toLowerCase(), searchToLowerCase) if org.name
        (name)
      )
      scope.organizations.displayList = $filter('orderBy')(scope.organizations.displayList, 'name')

    scope.searchChange = () ->
      if scope.organizations.search == ''
        setLastOrganizationsList()
      else
        setSearchOrganizationsList()

    scope.$watch('list', (newVals, oldVals) ->
      setLastOrganizationsList()
    , true)
)
