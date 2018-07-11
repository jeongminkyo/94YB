class NoticeComment < ApplicationRecord
  belongs_to :notice
  belongs_to :user
  resourcify
  include Authority::Abilities
end
