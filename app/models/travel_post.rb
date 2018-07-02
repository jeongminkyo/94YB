class TravelPost < ApplicationRecord
  has_many :travel_comments, dependent: :destroy
end
