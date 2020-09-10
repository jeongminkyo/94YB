class CashService < ApplicationService

  class << self
    def cash_list(page)
      cashes = Cash.cash_list(page)
      total_page = Cash.total_page
      wallet = Wallet.first

      {
          total_page: total_page,
          total_cash: wallet.current_money,
          total_cash_update_at: wallet.updated_at.strftime('%Y-%m-%d %H:%M:%S'),
          cashes: cashes
      }
    rescue ::YbErrors::Logic => e
      raise e
    rescue => e
      Rails.logger.warn(e, {}, { page: page }, CASH_LIST_ERROR)
      nil
    end

    def user_cash_list(user, page)
      cashes = Cash.user_cash_list(user.id, page)

      {
          total_page: Cash.user_total_page(user.id),
          cashes: cashes
      }
    rescue ::YbErrors::Logic => e
      raise e
    rescue => e
      Rails.logger.warn(e, {}, { page: page }, CASH_LIST_ERROR)
      nil
    end

    private


  end
end