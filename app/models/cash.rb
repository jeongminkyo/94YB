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

    def user_cash_list(user_id, page)
      cashes = self.select('cashes.id,
                   cashes.description,
                   cashes.money,
                   cashes.status,
                   cashes.date,
                   users.display_name')
                   .joins(:user).where(user_id: user_id).order('date desc, id desc').page(page).per(LIST_PER_PAGE).as_json
    end

    def total_page
      total_page = self.all.count / LIST_PER_PAGE  + 1
      if self.all.count % LIST_PER_PAGE == 0
        total_page = self.all.count / LIST_PER_PAGE
      end
      total_page
    end

    def user_total_page(user_id)
      total_page = self.where(user_id: user_id).count / LIST_PER_PAGE  + 1
      if self.where(user_id: user_id).count % LIST_PER_PAGE == 0
        total_page = self.where(user_id: user_id).count / LIST_PER_PAGE
      end
      total_page
    end
  end
end
