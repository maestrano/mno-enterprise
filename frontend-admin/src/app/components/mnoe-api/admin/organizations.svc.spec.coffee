describe('Service: MnoeOrganizations', ->

  beforeEach(module('frontendAdmin'))

  $httpBackend = null
  MnoeOrganizations = null

  beforeEach(inject((_MnoeOrganizations_, _$httpBackend_) ->
    MnoeOrganizations = _MnoeOrganizations_
    $httpBackend = _$httpBackend_

    # Backend interceptors
    $httpBackend.when('GET', '/mnoe/jpi/v1/admin/organizations').respond(200,
      {
        "organizations": [
          { "id": 9, "uid": "usr-fbbw", "name": "Marvel" },
          { "id": 10, "uid": "usr-fbb7", "name": "DC Comics" }
        ]
      })

    # Backend interceptors
    $httpBackend.when('GET', '/mnoe/jpi/v1/admin/organizations/in_arrears').respond(200,
      {
        "organization": [
          { "id": 9, "uid": "usr-fbbw", "name": "Marvel" }
        ]
      })

    # Backend interceptors
    $httpBackend.when('GET', '/mnoe/jpi/v1/admin/organizations/9').respond(200,
      {
        "organization": [
          { "id": 9, "uid": "usr-fbbw", "name": "Marvel" }
        ]
      })

    $httpBackend.when('GET', '/mnoe/jpi/v1/admin/organizations/count').respond(200,
      {
        "count": {
          "total_count": 7,
          "total_with_cc": 3
        }
      })
  ))

  afterEach( ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()
  )

  describe('@list', ->
    it('GETs /mnoe/jpi/v1/admin/organizations', ->
      $httpBackend.expectGET('/mnoe/jpi/v1/admin/organizations')
      MnoeOrganizations.list()
      $httpBackend.flush()
    )
  )

  describe('@inArrears', ->
    it('GETs /mnoe/jpi/v1/admin/in_arrears', ->
      $httpBackend.expectGET('/mnoe/jpi/v1/admin/organizations/in_arrears')
      MnoeOrganizations.inArrears()
      $httpBackend.flush()
    )
  )

  describe('@count', ->
    it('GETs /mnoe/jpi/v1/admin/organizations/count', ->
      $httpBackend.expectGET('/mnoe/jpi/v1/admin/organizations/count')
      MnoeOrganizations.count()
      $httpBackend.flush()
    )
  )
)
