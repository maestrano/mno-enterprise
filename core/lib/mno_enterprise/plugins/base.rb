module MnoEnterprise
  module Plugins
    class Base
      # == Constants ============================================================

      # == Attributes ===========================================================
      attr_accessor :config, :tenant

      # == Extensions ===========================================================
      include ActiveModel::Validations

      # == Relationships ========================================================

      # == Validations ==========================================================
      validate :must_match_json_schema

      # == Scopes ===============================================================

      # == Callbacks ============================================================

      # == Class Methods ========================================================
      # @return [Hash] Config JSON Schema
      def self.json_schema
        self::CONFIG_JSON_SCHEMA
      end

      # == Instance Methods =====================================================
      def initialize(tenant, config)
        plugin_key = self.class.name.demodulize.tableize
        @config = config.with_indifferent_access[plugin_key]
        @tenant = tenant
      end

      def save
        raise NotImplementedError
      end

      protected

      # Validates config against the JSON Schema
      def must_match_json_schema
        json_errors = JSON::Validator.fully_validate(self.class.json_schema, config)
        json_errors.each do |error|
          errors.add(:config, error)
        end
      end
    end
  end
end

