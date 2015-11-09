describe 'controllers', () ->
  vm = undefined

  beforeEach module 'frontendAdmin'

  beforeEach inject ($controller, webDevTec, toastr) ->
    spyOn(webDevTec, 'getTec').and.returnValue [{}, {}, {}, {}, {}]
    spyOn(toastr, 'info').and.callThrough()
    main = $controller 'DashboardController'

  it 'make sur the sidebar is toggled on init', () ->
    expect(main.toggle).toEqual true

  it 'toggle the sidebar', () ->
    main.toggleSidebar()
    expect(main.toggle).toEqual false
