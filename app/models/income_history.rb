class IncomeHistory < ApplicationRecord
  belongs_to :user
  belongs_to :cash

  class << self
    def user_income_history(user)
      IncomeHistory.select('month, money')
          .joins('join cashes on cashes.id = income_histories.cash_id')
          .where('user_id = ?', user.id).order('month')
    end
  end
end
