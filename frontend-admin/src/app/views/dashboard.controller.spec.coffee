describe 'controllers', () ->
  main = undefined

  beforeEach module 'frontendAdmin'

  beforeEach inject ($controller) ->
    main = $controller 'DashboardController'

  it 'make sure the sidebar is toggled on init', () ->
    expect(main.toggle).toEqual true

  it 'toggle the sidebar', () ->
    main.toggleSidebar()
    expect(main.toggle).toEqual false
