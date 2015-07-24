%w(core api frontend).each do |extension|
  require "mno_enterprise/#{extension}"
end
