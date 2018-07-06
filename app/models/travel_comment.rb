class TravelComment < ApplicationRecord
  belongs_to :travel_post
  resourcify
  include Authority::Abilities

  validates :body, presence: true
end
