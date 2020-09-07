module Api::V1
  class CashesController < ApplicationController

    skip_before_action :verify_authenticity_token

    # GET /api/v1/cashes
    def cash_list
      page = params[:page].blank? ? 1 : params[:page]

      @cashes = Cash.cash_list(page)
      total_page = Cash.total_page
      @wallet = Wallet.first

      cash_list = {
          total_page: total_page,
          total_cash: @wallet.current_money,
          total_cash_update_at: @wallet.updated_at.strftime('%Y-%m-%d %H:%M:%S'),
          cashes: @cashes
      }

      render json: cash_list
    end

    def user_cash_list
      page = params[:page].blank? ? 1 : params[:page]
      user_id = params[:user_id]
      @cashes = Cash.user_cash_list(user_id, page)

      cash_list = {
          total_page: Cash.user_total_page(user_id),
          cashes: @cashes
      }
      render json: cash_list
    end

    def account_info
      render json: {
          bank: '농협',
          account_num: '356-0022-3397-93'
      }
    end

    def create
      begin
        if params[:status].to_i == Cash::Status::INCOME
          Wallet.first.income_to_wallet(params[:money].to_i)
          params[:current_money] = Wallet.first.current_money
        elsif params[:status].to_i == Cash::Status::EXPENDITURE
          Wallet.first.expenditure_to_wallet(params[:money].to_i)
          params[:user_id] = User.find_by_email('admin@email.com').id
          params[:current_money] = Wallet.first.current_money
        end

        @cash = Cash.new(date: params[:date],
                 money: params[:money],
                 description: params[:description],
                 status: params[:status],
                 user_id: params[:user_id],
                 current_money: params[:current_money])

        @cash.save!

        render json: {}
      rescue => _e
        render json: {}, status: :internal_server_error
      end
    end
  end
end