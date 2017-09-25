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
    REQUIRED_HEADERS = %w(external_id company_name billing_currency name surname phone email address1 address2 state_province city postal_code)
    MANDATORY_COLUMNS = %w(company_name name surname email  address1 state_province city)
    CSV_OPTIONS = { headers: true, header_converters: lambda { |f| f.strip.parameterize.underscore }, converters: lambda { |f| f&.strip } }

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
        if row['external_id'].present?
          organization = MnoEnterprise::Organization.where(external_id: row['external_id']).first
        end
        if organization
          report[:organizations][:updated] << organization
        else
          organization = MnoEnterprise::Organization.new
          organization.external_id = row['external_id']
          report[:organizations][:added] << organization
        end
        organization.metadata ||= {}
        #metadata needs to be set to mark it as dirty and be properly saved
        organization.metadata = organization.metadata.merge(row.to_hash.slice(*%w(address1 address2 state_province, city postal_code)))
        organization.name = row['name']
        organization.billing_currency = row['billing_currency']
        organization.save
        user = MnoEnterprise::User.where(email: row['email']).first
        if user
          report[:users][:updated] << user
        else
          user = MnoEnterprise::User.new
          report[:users][:added] << user
          user.password = Devise.friendly_token
          user.email = row['email']
        end
        user.name = row['name']
        user.surname = row['surname']
        user.phone = row['phone']

        user.save
        orga_relation = MnoEnterprise::OrgaRelation.where(user_id: user.id, organization_id: organization.id).first
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
          errors << "Row: #{index}, Missing value for column: ''#{c}''." if row[c].blank?
        end
        email = row['email']
        if email.present? && Devise.email_regexp
          errors << "Row: #{index}, Invalid email: ''#{email}''" unless email =~ Devise.email_regexp
        end
        index += 1
      end
      errors
    end
  end
end

