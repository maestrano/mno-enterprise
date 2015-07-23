# TODO: PR to HER
# Fix to_params when embeded_params is nil
# Fix to_params when changes is nil 
# --> allow all params - this is required to be able to make class level 
#     requests like MyModel.post(path,{some: 'data'})
#
module Her
  module Model
    # This module handles resource data parsing at the model level (after the parsing middleware)
    module Parse
      extend ActiveSupport::Concern

      module ClassMethods

        # @private
        def to_params(attributes, changes = nil)
          filtered_attributes = attributes.dup.symbolize_keys
          filtered_attributes.merge!(embeded_params(attributes) || {})
          if her_api && her_api.options[:send_only_modified_attributes] && !changes.nil?
            filtered_attributes = changes.symbolize_keys.keys.inject({}) do |hash, attribute|
              hash[attribute] = filtered_attributes[attribute]
              hash
            end
          end

          if include_root_in_json?
            if json_api_format?
              { included_root_element => [filtered_attributes] }
            else
              { included_root_element => filtered_attributes }
            end
          else
            filtered_attributes
          end
        end
        
      end
    end
  end
end
