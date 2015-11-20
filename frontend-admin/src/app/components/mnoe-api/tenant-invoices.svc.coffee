# Service for managing the invoices.
@App.service 'MnoeTenantInvoices', (MnoeApiSvc) ->
  _self = @

  @list = () ->
    MnoeApiSvc.all('tenant_invoices').getList()

  return @
