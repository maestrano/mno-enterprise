describe('Service: MnoeInvoices', ->

  beforeEach(module('frontendAdmin'))

  $httpBackend = null
  MnoeInvoices = null

  beforeEach(inject((_MnoeInvoices_, _$httpBackend_) ->
    MnoeInvoices = _MnoeInvoices_
    $httpBackend = _$httpBackend_

    # Backend interceptors
    $httpBackend.when('GET', '/mnoe/jpi/v1/admin/invoices/current_billing').respond(200,
      {
        current_billing_amount: { amount: 2000, currency: 'AUD' }
      })
    $httpBackend.when('GET', '/mnoe/jpi/v1/admin/invoices/last_invoicing_amount').respond(200,
      {
        last_invoicing_amount: { amount: 2000, currency: 'AUD' }
      })
    $httpBackend.when('GET', '/mnoe/jpi/v1/admin/invoices/outstanding_amount').respond(200,
      {
        outstanding_amount: { amount: 2000, currency: 'AUD' }
      })
  ))

  afterEach( ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()
  )

  describe('@currentBilling', ->
    it('GETs /mnoe/jpi/v1/admin/invoices/current_billing', ->
      $httpBackend.expectGET('/mnoe/jpi/v1/admin/invoices/current_billing')
      MnoeInvoices.currentBilling()
      $httpBackend.flush()
    )
  )

  describe('@lastInvoicingAmount', ->
    it('GETs /mnoe/jpi/v1/admin/invoices/last_invoicing_amount', ->
      $httpBackend.expectGET('/mnoe/jpi/v1/admin/invoices/last_invoicing_amount')
      MnoeInvoices.lastInvoicingAmount()
      $httpBackend.flush()
    )
  )

  describe('@outstandingAmount', ->
    it('GETs /mnoe/jpi/v1/admin/invoices/outstanding_amount', ->
      $httpBackend.expectGET('/mnoe/jpi/v1/admin/invoices/outstanding_amount')
      MnoeInvoices.outstandingAmount()
      $httpBackend.flush()
    )
  )

)
