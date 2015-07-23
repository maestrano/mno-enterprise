module Her
  module Model
    # TODO: make PR to Her project
    # This patch fixes the detection of changed attributes
    module Attributes
      extend ActiveSupport::Concern


      module ClassMethods
        # Define the attributes that will be used to track dirty attributes and validations
        #
        # @param [Array] attributes
        # @example
        #   class User
        #     include Her::Model
        #     attributes :name, :email
        #   end
        def attributes(*attributes)
          define_attribute_methods attributes

          attributes.each do |attribute|
            attribute = attribute.to_sym

            unless instance_methods.include?(:"#{attribute}=")
              define_method("#{attribute}=") do |value|
                @attributes[:"#{attribute}"] = nil unless @attributes.include?(:"#{attribute}")
                self.send(:"#{attribute}_will_change!") if @attributes[:"#{attribute}"] != value
                @attributes[:"#{attribute}"] = value
              end
            end

            unless instance_methods.include?(:"#{attribute}?")
              define_method("#{attribute}?") do
                @attributes.include?(:"#{attribute}") && @attributes[:"#{attribute}"].present?
              end
            end
          end
        end
        
      end
    end
  end
end
