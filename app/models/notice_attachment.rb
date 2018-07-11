class NoticeAttachment < ApplicationRecord
  mount_uploader :s3, S3Uploader
  belongs_to :notice
end
