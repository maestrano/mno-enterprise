%w(core frontend).each do |extension|
  require "mno_enterprise/#{extension}"
end
