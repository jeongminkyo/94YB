class PostAttachment < ApplicationRecord
  mount_uploader :s3, S3Uploader
  belongs_to :post
end
