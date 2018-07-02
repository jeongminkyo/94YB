class TravelPostAttachment < ApplicationRecord
  mount_uploader :s3, S3Uploader
  belongs_to :travel_post
end
