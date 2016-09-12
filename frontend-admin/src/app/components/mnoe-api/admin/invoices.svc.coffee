# Service for managing the invoices.
@App.service 'MnoeInvoices', (MnoeAdminApiSvc) ->
  _self = @

  @currentBillingAmount = () ->
    MnoeAdminApiSvc.all('invoices').customGET('current_billing_amount')

  @lastInvoicingAmount = () ->
    MnoeAdminApiSvc.all('invoices').customGET('last_invoicing_amount')

  @outstandingAmount = () ->
    MnoeAdminApiSvc.all('invoices').customGET('outstanding_amount')

  @lastPortfolioAmount = ->
    MnoeAdminApiSvc.all('invoices').customGET('last_portfolio_amount')

  @lastCommissionAmount = ->
    MnoeAdminApiSvc.all('invoices').customGET('last_commission_amount')

  return @
