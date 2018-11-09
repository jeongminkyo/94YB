class Cash < ApplicationRecord
  resourcify
  has_many :income_histories
  include Authority::Abilities

  module Status
    INCOME = 0
    EXPENDITURE= 1
  end

end
