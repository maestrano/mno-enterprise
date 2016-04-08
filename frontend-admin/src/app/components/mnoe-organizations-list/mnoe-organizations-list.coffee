#
# Mnoe organizations List
#
@App.directive('mnoeOrganizationsList', ($filter, $log, MnoeOrganizations) ->
  restrict: 'E'
  scope: {
    list: '='
  },
  templateUrl: 'app/components/mnoe-organizations-list/mnoe-organizations-list.html',
  link: (scope, elem, attrs) ->

    # Widget state
    scope.state = attrs.view

    # Variables initialization
    scope.organizations =
      search: ''
      nbItems: 10
      page: 1
      pageChangedCb: (nbItems, page) ->
        scope.organizations.nbItems = nbItems
        scope.organizations.page = page
        offset = (page  - 1) * nbItems
        fetchOrganizations(nbItems, offset)

    # Fetch organisations
    fetchOrganizations = (limit, offset, sort = 'name') ->
      scope.organizations.loading = true
      return MnoeOrganizations.list(limit, offset, sort).then(
        (response) ->
          scope.organizations.totalItems = response.headers('x-total-count')
          scope.organizations.list = response.data
      ).then(-> scope.organizations.loading = false)

    scope.switchState = () ->
      scope.state = attrs.view = if attrs.view == 'all' then 'last' else 'all'
      displayCurrentState()

    # if view="all" is set on the directive, all the users are displayed
    # if view="last" is set on the directive, the last 10 users are displayed
    displayCurrentState = () ->
      if attrs.view == 'all'
        setAllOrganizationsList()
        fetchOrganizations(scope.organizations.nbItems, 0)
      else if attrs.view == 'last'
        setLastOrganizationsList()
        fetchOrganizations(scope.organizations.nbItems, 0, 'created_at.desc')
      else
        $log.error('Value of attribute view can only be "all" or "last"')

    # Display all the organisations
    setAllOrganizationsList = () ->
      scope.organizations.widgetTitle = 'All organisations'
      scope.organizations.switchLinkTitle = '(last 10)'

    # Display only the last 10 organisations
    setLastOrganizationsList = () ->
      scope.organizations.widgetTitle = 'Last 10 organisations'
      scope.organizations.switchLinkTitle = '(view all)'

    scope.searchChange = () ->
      # Only search if the string is >= than 3 characters
      if scope.organizations.search.length >= 3
        scope.searchMode = true
        setSearchOrganizationsList(scope.organizations.search)
      # No search string, so display current state
      else if scope.searchMode
        scope.searchMode = false
        displayCurrentState()

    # Display only the search results
    setSearchOrganizationsList = (search) ->
      scope.organizations.loading = true
      scope.organizations.widgetTitle = 'Search result'
      delete scope.organizations.switchLinkTitle
      search = scope.organizations.search.toLowerCase()
      terms = {'name.like': "%#{search}%"}
      MnoeOrganizations.search(terms).then(
        (response) ->
          scope.organizations.totalItems = response.headers('x-total-count')
          scope.organizations.list = $filter('orderBy')(response.data, 'name')
      ).finally(-> scope.organizations.loading = false)

    # Initial call
    displayCurrentState()
)
