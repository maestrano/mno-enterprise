@tickets.each do |ticket|
  json.set! "ticket#{ticket.id}" do
    json.partial! 'show', ticket: ticket
  end
end
