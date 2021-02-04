module Api::V1
  class CashesController < ApplicationController

    skip_before_action :verify_authenticity_token
    prepend_before_action only: [:cash_list, :user_cash_list] do
      set_user_by_access_token(request.headers['X-YB-ACCESS-TOKEN'])
    end

    before_action only: [:cash_list, :user_cash_list] do
      check_authenticate_member(@user)
    end

    # GET /api/v1/cashes
    def cash_list
      log_options = { log_event_code: CASH_LIST_ERROR }
      page = params[:page].blank? ? 1 : params[:page]

      cash_list = CashService.cash_list(page)
      raise InternalServer.new(log_options.merge({ log_message: 'cash list load fail' })) if cash_list.nil?

      render yb:cash_list, status: :ok
    end

    def user_cash_list
      log_options = { log_event_code: CASH_LIST_ERROR }
      page = params[:page].blank? ? 1 : params[:page]

      cash_list = CashService.user_cash_list(@user, page)
      raise InternalServer.new(log_options.merge({ log_message: 'cash list load fail'})) if cash_list.nil?

      render yb:cash_list, status: :ok
    end

    def account_info
      render json: {
          bank: '농협',
          account_num: '356-1100-0267-33'
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