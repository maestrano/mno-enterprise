# > UpdateIntercomUsers.run(batch_size: 50)
class UpdateIntercomUsers
  MAX_REQUEST_ATTEMPTS = 3

  def self.run(*args)
    new(*args).run
  end

  attr_accessor :intercom_listener
  attr_accessor :batch_size
  attr_accessor :total_sent
  attr_accessor :from_date
  def initialize(options = {})
    self.intercom_listener = MnoEnterprise::IntercomEventsListener.new
    self.batch_size = options[:batch_size] || 50
  end

  def assert_runnable
    raise ImportError, 'Please add an Intercom API Key' unless MnoEnterprise.intercom_enabled?
    info 'Intercom API key found'
  end

  def run
    assert_runnable
    skip =  0
    total_count = 0
    loop do
      users = MnoEnterprise::User.limit(self.batch_size).skip(skip).all.fetch
      total_count = users.metadata[:pagination][:count]
      users.to_a.each do |user|
        update_user(user)
      end
      info "Successfully updated #{users.size} users", new_line: true
      skip += self.batch_size
      break unless skip < total_count
    end
    info "Successfully updated #{total_count} users", new_line: true
  end

  def update_user(user, attempts = 0)
    self.intercom_listener.update_intercom_user(user, false)
    rescue Intercom::IntercomError => e
      if attempts < MAX_REQUEST_ATTEMPTS
        sleep(0.5)
        update_user(user, attempts + 1)
      else
        raise
      end
  end

  def info(str, options = {})
    puts "#{"\n" if options[:new_line]}* #{str}"
  end
end
