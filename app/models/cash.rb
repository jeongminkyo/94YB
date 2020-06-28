class Cash < ApplicationRecord
  resourcify
  belongs_to :user
  include Authority::Abilities

  LIST_PER_PAGE = 20

  module Status
    INCOME = 0
    EXPENDITURE = 1
  end

  class << self
    def user_cash_history(user)
      cash_history = user.cashes
    end

    def cash_list(page)
      cashes = self.select('cashes.id,
                   cashes.description,
                   cashes.money,
                   cashes.status,
                   cashes.date,
                   users.display_name')
          .joins(:user).order('date desc, id desc').page(page).per(LIST_PER_PAGE).as_json
    end
  end
end
