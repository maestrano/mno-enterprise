json.sub_tenants @sub_tenants, partial: 'sub_tenant', as: :sub_tenant
json.metadata @sub_tenants.metadata if @sub_tenants.respond_to?(:metadata)
