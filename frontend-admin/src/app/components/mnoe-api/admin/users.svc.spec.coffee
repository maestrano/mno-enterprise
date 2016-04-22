describe('Service: MnoeUsers', ->

  beforeEach(module('frontendAdmin'))

  $httpBackend = null
  MnoeUsers = null

  beforeEach(inject((_MnoeUsers_, _$httpBackend_) ->
    MnoeUsers = _MnoeUsers_
    $httpBackend = _$httpBackend_

    # Backend interceptors
    $httpBackend.when('GET', '/mnoe/jpi/v1/admin/users').respond(200,
      {
        "users": [
          { "id": 9, "uid": "usr-4l0e", "email": "alex.jarnoux@gmail.com", "name": "Alex", "surname": "Jarnoux", "admin_role": "admin", "created_at": "2015-11-01T03:26:16.000Z" },
          { "id": 10, "uid": "usr-4l04", "email": "charles.xavier@maestrano.com", "name": "Charles", "surname": "Xavier", "admin_role": null, "created_at": "2015-11-01T03:36:00.000Z" }
        ]
      })

    # Backend interceptors
    $httpBackend.when('GET', '/mnoe/jpi/v1/admin/users/10').respond(200,
      {
        "user": [
          { "id": 10, "uid": "usr-4l04", "email": "charles.xavier@maestrano.com", "name": "Charles", "surname": "Xavier", "admin_role": null, "created_at": "2015-11-01T03:36:00.000Z" }
        ]
      })

    $httpBackend.when('GET', '/mnoe/jpi/v1/admin/users/count').respond(200,
      {
        "count": {
          "total_count": 14,
          "count_new_month": 4
        }
      })
  ))

  afterEach( ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()
  )

  describe('@list', ->
    it('GETs /mnoe/jpi/v1/admin/users', ->
      $httpBackend.expectGET('/mnoe/jpi/v1/admin/users')
      MnoeUsers.list()
      $httpBackend.flush()
    )
  )

  describe('@get', ->
    it('GETs /mnoe/jpi/v1/admin/users/10', ->
      $httpBackend.expectGET('/mnoe/jpi/v1/admin/users/10')
      MnoeUsers.get(10)
      $httpBackend.flush()
    )
  )

  describe('@count', ->
    it('GETs /mnoe/jpi/v1/admin/users/count', ->
      $httpBackend.expectGET('/mnoe/jpi/v1/admin/users/count')
      MnoeUsers.count()
      $httpBackend.flush()
    )
  )
)
