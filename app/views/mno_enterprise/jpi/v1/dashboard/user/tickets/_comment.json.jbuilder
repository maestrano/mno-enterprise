comment ||= @comment

json.id comment.id
json.body comment.html_body
json.created_at comment.created_at.to_formatted_s(:short)
json.author_name @author_name || @authors["author#{comment.author_id}"][:name]
json.attachments do
  json.array! comment.attachments do |attachment|
    json.file_name attachment.file_name
    json.content_url attachment.content_url
    if attachment.thumbnails && attachment.thumbnails.first
      json.thumbnail attachment.thumbnails.first.content_url
    end
  end
end
