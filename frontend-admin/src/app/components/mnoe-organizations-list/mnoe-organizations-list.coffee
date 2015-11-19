#
# Mnoe organizations List
#
@App.directive('mnoeOrganizationsList', ($filter, $log) ->
  restrict: 'E'
  scope: {
    list: '='
  },
  templateUrl: 'app/components/mnoe-organizations-list/mnoe-organizations-list.html',
  link: (scope, elem, attrs) ->

    # Variables initialization
    scope.organizations =
      displayList: []
      widgetTitle: 'Loading organisations...'
      search: ''

    # Display all the organisations
    setAllOrganizationsList = () ->
      scope.organizations.widgetTitle = 'All organisations (' + scope.list.length + ')'
      scope.organizations.switchLinkTitle = '(last 10)'
      scope.organizations.displayList = $filter('orderBy')(scope.list, 'name')

    # Display only the last 10 organisations
    setLastOrganizationsList = () ->
      scope.organizations.widgetTitle = 'Last 10 organisations'
      scope.organizations.switchLinkTitle = '(view all)'
      scope.organizations.displayList = $filter('orderBy')(scope.list, '-created_at')
      scope.organizations.displayList = $filter('limitTo')(scope.organizations.displayList, 10)

    # Display only the search results
    setSearchOrganizationsList = () ->
      scope.organizations.widgetTitle = 'Search result'
      delete scope.organizations.switchLinkTitle
      searchToLowerCase = scope.organizations.search.toLowerCase()
      scope.organizations.displayList = _.filter(scope.list, (org) ->
        name = _.contains(org.name.toLowerCase(), searchToLowerCase) if org.name
        (name)
      )
      scope.organizations.displayList = $filter('orderBy')(scope.organizations.displayList, 'name')

    displayNormalState = () ->
      # if view="all" is set on the directive, all the users are displayed
      # if view="last" is set on the directive, the last 10 users are displayed
      if attrs.view == 'all'
        setAllOrganizationsList()
      else if attrs.view == 'last'
        setLastOrganizationsList()
      else
        $log.error('Value of attribute view can only be "all" or "last"')

    scope.switchState = () ->
      if attrs.view == 'all'
        attrs.view = 'last'
      else
        attrs.view = 'all'
      displayNormalState()

    scope.searchChange = () ->
      if scope.organizations.search == ''
        setLastOrganizationsList()
      else
        setSearchOrganizationsList()

    scope.$watch('list', (newVal, oldVal) ->
      if newVal
        displayNormalState()
    , true)
)
