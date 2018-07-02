class TravelComment < ApplicationRecord
  belongs_to :travel_post
  validates :body, presence: true
end
