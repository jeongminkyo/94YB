class TravelComment < ApplicationRecord
  belongs_to :travel_post
  belongs_to :user
  resourcify
  include Authority::Abilities

  validates :body, presence: true
end
