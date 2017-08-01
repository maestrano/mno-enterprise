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

      private

      # Return the I18n translation hash
      def get_translations
        I18n.translate(:foo) # Need to do this to force I18n init
        I18n.backend.send(:translations)
      end

      # Write the json file
      def generate_locale(locale_code, translation_hash)
        locale = {}
        flatten_translations('', translation_hash, locale)

        output_file = File.join(@path, "#{locale_code}.locale.json")

        File.open(output_file, 'w') {|f| f.write(JSON.pretty_generate(locale)) }
        puts "--> Generated #{output_file}"
      end

      # Flatten key
      # print_translations("", {foo: {bar: 'baz'}}, locale)
      #  => locale = {'foo.bar' => 'baz'}
      def flatten_translations(prefix, x, locale)
        if x.is_a? Hash
          if (not prefix.empty?)
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
