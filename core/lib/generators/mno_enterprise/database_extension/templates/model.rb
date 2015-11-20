module MnoEnterprise
  class <%= class_name %> < BaseResource
    include MnoEnterprise::Concerns::Models::<%= class_name %>

    include MnoEnterprise::DatabaseExtendable

    database_extendable <%= fields.map {|field| ":#{field.split(':').first}"}.join(', ') %>
  end
end
