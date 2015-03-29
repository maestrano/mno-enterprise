# organization ||= @organization
#
# json.invoices do
#   json.array! organization.invoices.order("ended_at DESC") do |invoice|
#     json.period invoice.period_label
#     json.amount invoice.total_due
#     json.paid invoice.paid?
#     json.link invoice_path(invoice.slug)
#   end
# end