class Comment < ApplicationRecord
  resourcify
  include Authority::Abilities
  belongs_to :post
  validates :body, presence: true
end
