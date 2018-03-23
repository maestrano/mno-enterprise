module MnoEnterprise

  class CSVImportError < StandardError
    attr_reader :errors

    def initialize(errors)
      super(errors.first)
      @errors = errors
    end
  end

  class CSVImporter
    # CSV IMPORT
    REQUIRED_HEADERS = %w(external_id company_name billing_currency name surname phone email address1 address2 city state_province country postal_code)
    MANDATORY_COLUMNS = %w(company_name name surname email address1 city state_province country)
    CSV_OPTIONS = { encoding: "ISO8859-1:utf-8", headers: true, header_converters: lambda { |f| f.strip.parameterize.underscore }, converters: lambda { |f| f&.strip } }

    def self.process(file_path)
      # validate File
      begin
        csv = CSV.read(file_path, CSV_OPTIONS)
      rescue CSV::MalformedCSVError => e
        raise CSVImportError.new(["Could not Process CSV File: #{e.message}"])
      end
      errors = validate_csv(csv)
      if errors.any?
        raise CSVImportError.new(errors)
      end
      report = { organizations: { added: [], updated: [] }, users: { added: [], updated: [] } }
      # TODO Move to a Job
      csv.each do |row|
        # Create or Update Organization
        if row['external_id'].present?
          organization = MnoEnterprise::Organization.where(external_id: row['external_id']).first
        end
        event_type = if organization
                       :updated
                     else
                       organization = MnoEnterprise::Organization.new
                       organization.external_id = row['external_id']
                       :added
                     end
        organization.name = row['company_name']
        organization.billing_currency = row['billing_currency']
        organization.save

        if event_type == :added
          add_address(row, organization)
        end

        report[:organizations][event_type] << organization

        # Create or Update User
        user = MnoEnterprise::User.where(email: row['email']).first
        event_type = if user
                       :updated
                     else
                       user = MnoEnterprise::User.new
                       user.password = Devise.friendly_token
                       user.email = row['email']
                       :added
                     end

        user.name = row['name']
        user.surname = row['surname']
        user.phone = row['phone']
        user.save

        if event_type == :added
          add_address(row, user)
        end

        user = user.load_required(:sub_tenant)
        report[:users][event_type] << user

        orga_relation = MnoEnterprise::OrgaRelation.where(user_id: user.id, organization_id: organization.id).first
        # Add User as Super Admin to Organization if he is not already in it
        unless orga_relation
          MnoEnterprise::OrgaRelation.create(user_id: user.id, organization_id: organization.id, role: 'Super Admin')
        end
      end
      report
    end

    def self.validate_csv(csv)
      errors = []
      missing_headers = REQUIRED_HEADERS - csv.headers
      if (missing_headers.any?)
        errors << "Headers are missing: #{missing_headers.to_sentence}"
        return errors
      end
      index = 1
      csv.each do |row|
        MANDATORY_COLUMNS.each do |c|
          errors << "Row: #{index}, Missing value for column: '#{c}'." if row[c].blank?
        end
        errors << "Row: #{index}, Invalid Country code '#{row['country']}'. It must follow ISO 3166 Standard two-letter country codes." unless ISO3166::Country.codes.include?(row['country'])
        email = row['email']
        if email.present? && Devise.email_regexp
          errors << "Row: #{index}, Invalid email: '#{email}'" unless email =~ Devise.email_regexp
        end
        index += 1
      end
      errors
    end

    def self.add_address(row, owner)
      address = MnoEnterprise::Address.new(
        city:         row['city'],
        country_code: row['country'],
        street: [row['address1'], row['address2']].reject(&:blank?).join(' '),
        state_code: row['state_province'],
        postal_code: row['postal_code']
      )
      address.relationships.owner = owner
      address.save
    end
  end
end
