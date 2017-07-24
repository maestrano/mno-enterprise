module MnoEnterprise
  class App < BaseResource

    property :created_at, type: :time
    property :updated_at, type: :time

    custom_endpoint :regenerate_api_key, on: :member, request_method: :patch

    # Return the list of available categories
    def self.categories(list = nil)
      app_list = list || self.all.to_a
      app_list.select { |a| a.categories.present? }.map(&:categories).flatten.uniq { |e| e.downcase }.sort
    end

    # Methods for appinfo flags
    %w(responsive coming_soon single_billing add_on).each do |method|
      define_method "#{method}?" do
        !!(appinfo.presence && appinfo[method])
      end
    end

    def star_ready?
      !!(appinfo.presence && appinfo['starReady'])
    end

    def connec_ready?
      !!(appinfo.presence && appinfo['connecReady'])
    end

    # Sanitize the app description
    # E.g.: replace any mention of Maestrano by the tenant name
    def sanitized_description
      @sanitized_description ||= (self.description || '').gsub(/(?!cdn\.)maestrano(?!\.com)/i,MnoEnterprise.app_name)
    end

    def regenerate_api_key!
      data = self.regenerate_api_key
      self.api_key = data.first.api_key
    end

    def to_audit_event
      {
        app_id: id,
        app_nid: nid,
        app_name: name
      }
    end
  end
end
