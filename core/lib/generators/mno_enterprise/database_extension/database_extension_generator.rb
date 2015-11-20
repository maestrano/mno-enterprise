class MnoEnterprise::DatabaseExtensionGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  argument :fields, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"

  # Check the class we want to extend exists
  def check_class_exists
    klass = "MnoEnterprise::#{class_name}"
    klass.constantize
  rescue NameError
     raise Thor::Error, "The class '#{klass}' does not exist in Maestrano Enterprise"
  end

  def check_class_is_decorator_ready
    klass = "MnoEnterprise::Concerns::Models::#{class_name}"
    klass.constantize
  rescue NameError
    raise Thor::Error, "The class '#{class_name}' is not decorator ready. Please extract it to #{klass}."
  end

  # Check the class we want to extend doesn't exist
  def check_class_collision
    @model_name = "MnoEnterprise::#{class_name}Extension"
    @model_name.constantize rescue nil # To preload class in dev?
    class_collisions @model_name
  end

  def generate_extension_model
    params = "#{@model_name} #{file_name}_uid:string:uniq " + fields.join(' ') + " --no-fixture -t rspec"
    generate "model", params
  end

  def generate_mnoe_model
    template 'model.rb', File.join('app/models/mno_enterprise', "#{file_name}.rb")
  end
end
