class Cash < ApplicationRecord
  resourcify
  belongs_to :user
  include Authority::Abilities

  module Status
    INCOME = 0
    EXPENDITURE = 1
  end

  class << self
    def user_cash_history(user)
      cash_history = user.cashes
    end
  end
end
