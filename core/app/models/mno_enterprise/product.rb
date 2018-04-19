module MnoEnterprise
  class Product < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time

    property :nid, type: :string
    property :name, type: :string
    property :active, type: :boolean
    property :product_type, type: :string
    property :logo, type: :string
    property :custom_schema, type: :string
    property :provisioning_url, type: :string
    property :external_id, type: :string
    property :externally_provisioned, type: :boolean
    property :parent_id, type: :string
    property :local, type: :boolean
    property :free_trial_enabled, type: :boolean
    property :free_trial_duration, type: :integer
    property :free_trial_unit, type: :string

    def values_attributes
      product_values = {}

      values.each do |value|
        nid = value.field&.nid

        if nid
          # Some fields will be valid JSON, whereas others will be simple strings.
          begin
            data = JSON.parse(value.data)
          rescue
            data = value.data
          end
          product_values[nid] = data
        end
      end

      product_values
    end

    def self.categories(list = nil)
      product_list = list || self.all.to_a

      categories = []
      product_list.each do |p|
        categories += p.product_categories
      end

      categories.uniq { |cat| cat.downcase }.sort
    end

    def product_categories
      categories.map do |c|
        # Only find top-level categories
        next if c.parent_id
        c.name
      end
    end

    def to_audit_event
      {
        id: id,
        nid: nid,
        name: name,
        product_type: product_type
      }
    end
  end
end
