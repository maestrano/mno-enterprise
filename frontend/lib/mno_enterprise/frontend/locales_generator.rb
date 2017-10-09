# TODO:
#  - Filter frontend keys
#  - minify?
module MnoEnterprise
  module Frontend
    class LocalesGenerator

      def initialize(path)
        @path = path
      end

      # Generate JSON locales
      def generate_json
        translations_hash = get_translations

        translations_hash.each do |locale, translations|
          generate_locale(locale, translations)
        end
      end

      def generate_dummy
        translations_hash = get_translations
        base = translations_hash[:en].dup
        target = translations_hash[:zh]

        target.delete_if {|k,v| k != :mno_enterprise}
        base.delete_if {|k,v| k != :mno_enterprise}

        # prune_translation(base, target)
        dummy_translate(base)

        output = {zh: base}
        output_file = File.join(@path, "dummy.zh.yaml")

        File.open(output_file, 'w') {|f| f.write(output.to_yaml) }
        puts "--> Generated #{output_file}"
      end

      def prune_translation(base, target)
        target.each do |key, value|
          next unless base.has_key?(key)
          if value.is_a?(Hash)
            prune_translation(base[key], target[key])
            base.delete(key) if base[key].empty?
          elsif value.is_a?(String)
            base.delete(key)
          else
            puts value.class.inspect
          end
        end
      end

      def dummy_translate(base)
        base.each do |key, value|
          if value.is_a?(Hash)
            dummy_translate(value)
          elsif value.is_a?(String)
            base[key] = [*"\u4E00".."\u9FFF"].sample(Random.rand(2..6)).join('')
          else
            puts value.class
          end
        end
      end

      private

      # Return the I18n translation hash
      def get_translations
        I18n.translate(:foo) # Need to do this to force I18n init
        I18n.backend.send(:translations)
      end

      # Write the json file
      def generate_locale(locale_code, translation_hash)
        locale = impac_translation_hash(locale_code)
        flatten_translations('', translation_hash, locale)

        output_file = File.join(@path, "#{locale_code}.json")

        File.open(output_file, 'w') {|f| f.write(JSON.pretty_generate(locale)) }
        puts "--> Generated #{output_file}"
      end

      # If an impac locale file exist, use it as the base for translation
      # It's then overriden by the App translation
      def impac_translation_hash(locale_code)
        file = File.join(@path, 'impac', "#{locale_code}.json")
        if File.exist?(file)
          JSON.parse(File.read(file))
        else
          {}
        end
      end

      # Flatten key
      # print_translations("", {foo: {bar: 'baz'}}, locale)
      #  => locale = {'foo.bar' => 'baz'}
      def flatten_translations(prefix, x, locale)
        if x.is_a? Hash
          unless prefix.empty?
            prefix += "."
          end
          x.each {|key, value|
            flatten_translations(prefix + key.to_s, value, locale)
          }
        else
          locale[prefix] = x
          locale
        end
      end
    end
  end
end
