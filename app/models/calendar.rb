class Calendar < ApplicationRecord
  belongs_to :user
  attr_accessor :date_range
end
