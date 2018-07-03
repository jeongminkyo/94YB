class TravelPostLike < ApplicationRecord
  belongs_to :travel_post
  belongs_to :user
end
