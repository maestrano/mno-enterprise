# Service for managing the invoices.
@App.service 'MnoeInvoices', (MnoeApiSvc) ->
  _self = @

  @currentBilling = () ->
    MnoeApiSvc.all('invoices').customGET('current_billing')

  @lastInvoicingAmount = () ->
    MnoeApiSvc.all('invoices').customGET('last_invoicing_amount')

  @outstandingAmount = () ->
    MnoeApiSvc.all('invoices').customGET('outstanding_amount')

  return @
