json.extract! notice_attachment, :id, :notice_id, :s3, :created_at, :updated_at
json.url notice_attachment_url(notice_attachment, format: :json)
