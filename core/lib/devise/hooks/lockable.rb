# using current version https://github.com/plataformatec/devise/blob/e841c4c5ef826b6838b269d259170bb4fbca82f1/lib/devise/hooks/lockable.rb
# as 3-stable version https://github.com/plataformatec/devise/blob/3-stable/lib/devise/hooks/lockable.rb
# is using update_attribute which is not supported by Her
# After each sign in, if resource responds to failed_attempts, sets it to 0
# This is only triggered when the user is explicitly set (with set_user)
Warden::Manager.after_set_user except: :fetch do |record, warden, options|
  if record.respond_to?(:failed_attempts) && warden.authenticated?(options[:scope])
    unless record.failed_attempts.to_i.zero?
      record.failed_attempts = 0
      record.save(validate: false)
    end
  end
end
