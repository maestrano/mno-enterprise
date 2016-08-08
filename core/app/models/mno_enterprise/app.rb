# == Schema Information
#
# Endpoint: /v1/apps
#
#  id                       :integer         not null, primary key
#  nid                      :string         e.g.: 'wordpress'
#  name                     :string(255)
#  description              :text
#  created_at               :datetime        not null
#  updated_at               :datetime        not null
#  logo                     :string(255)
#  version                  :string(255)
#  website                  :string(255)
#  slug                     :string(255)
#  categories               :text
#  key_benefits             :text
#  key_features             :text
#  testimonials             :text
#  worldwide_usage          :integer
#  tiny_description         :text
#  popup_description        :text
#  stack                    :string(255)
#  terms_url                :string(255)
#  tags                     :text
#  rank                     :integer
#

module MnoEnterprise
  class App < BaseResource
    scope :active, -> { where(active: true) }
    scope :cloud, -> { where(stack: 'cloud') }

    attributes :id, :uid, :nid, :name, :description, :tiny_description, :created_at, :updated_at, :logo, :website, :slug,
    :categories, :key_benefits, :key_features, :testimonials, :worldwide_usage, :tiny_description,
    :popup_description, :stack, :terms_url, :pictures, :tags, :api_key, :metadata_url, :metadata, :details, :rank

    # Return the list of available categories
    def self.categories(list = nil)
      app_list = list || self.all.to_a
      app_list.select { |a| a.categories.present? }.map(&:categories).flatten.uniq { |e| e.downcase }.sort
    end

    def to_audit_event
      {
        app_id: id,
        app_nid: nid,
        app_name: name
      }
    end

    # Sanitize the app description
    # E.g.: replace any mention of Maestrano by the tenant name
    def sanitized_description
      @sanitized_description ||= (self.description || '').gsub(/maestrano/i,MnoEnterprise.app_name)
    end

    # Methods for appinfo flags
    %w(coming_soon single_billing add_on).each do |method|
      define_method "#{method}?" do
        appinfo.presence && appinfo[method]
      end
    end

    def regenerate_api_key!
      data = self.put(operation: 'regenerate_api_key')
      self.api_key = data[:data][:api_key]
    end

    def refresh_metadata!(metadata_url)
      self.put(operation: 'refresh_metadata', metadata_url: metadata_url)
    end
  end
end
