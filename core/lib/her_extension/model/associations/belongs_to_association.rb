# Backport https://github.com/remiprev/her/pull/343/files
# Fix belongs_to when foreign key is nil
module Her
  module Model
    module Associations
      class BelongsToAssociation < Association
        # @private
        def fetch
          foreign_key_value = @parent.attributes[@opts[:foreign_key].to_sym]
          data_key_value = @parent.attributes[@opts[:data_key].to_sym]
          return @opts[:default].try(:dup) if (@parent.attributes.include?(@name) && @parent.attributes[@name].nil? && @params.empty?) || (foreign_key_value.blank? && data_key_value.blank?)

          return @cached_result unless @params.any? || @cached_result.nil?
          return @parent.attributes[@name] unless @params.any? || @parent.attributes[@name].blank?

          path_params = @parent.attributes.merge(@params.merge(@klass.primary_key => foreign_key_value))
          path = build_association_path lambda { @klass.build_request_path(path_params) }
          @klass.get(path, @params).tap do |result|
            @cached_result = result if @params.blank?
          end
        end
      end
    end
  end
end
