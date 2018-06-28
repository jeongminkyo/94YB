class Post < ApplicationRecord
  belongs_to :user
  mount_uploader :image, S3Uploader
end
