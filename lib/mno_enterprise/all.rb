%w(core).each do |extension|
  require "mno_enterprise/#{extension}"
end
