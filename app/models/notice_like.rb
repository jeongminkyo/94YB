class NoticeLike < ApplicationRecord
  belongs_to :notice
  belongs_to :user
end
