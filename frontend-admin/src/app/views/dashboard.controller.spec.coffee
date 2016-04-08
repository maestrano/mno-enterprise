describe 'controllers', () ->
  scope = undefined

  beforeEach module 'frontendAdmin'

  beforeEach inject ($controller) ->
    scope = $controller('DashboardController')

  it 'make sure the sidebar is toggled on init', () ->
    expect(scope.main.toggle).toEqual true
    console.log "### MAIN:", scope.main

  it 'toggle the sidebar', () ->
    main.toggleSidebar()
    expect(scope.main.toggle).toEqual false
    console.log "### MAIN:", scope.main
