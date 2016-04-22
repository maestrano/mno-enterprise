# Service for managing the invoices.
@App.service 'MnoeTenantInvoices', (MnoeAdminApiSvc) ->
  _self = @

  @list = () ->
    MnoeAdminApiSvc.all('tenant_invoices').getList()

  return @
