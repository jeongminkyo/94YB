class TravelPost < ApplicationRecord
  has_many :travel_comments, dependent: :destroy
  has_many :travel_post_attachments
  has_many :travel_post_likes
  accepts_nested_attributes_for :travel_post_attachments
end
