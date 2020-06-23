module Api::V1
  class CashesController < ApplicationController

    # GET /api/v1/cashes
    def cash_list
      page = params[:page].blank? ? 1 : params[:page]

      @cashes = Cash.cash_list(page)
      @wallet = Wallet.first

      cash_list = {
          total_cash: @wallet.current_money,
          total_cash_update_at: @wallet.updated_at.strftime('%Y-%m-%d %H:%M:%S'),
          cashes: @cashes
      }

      render json: cash_list
    end


  end
end