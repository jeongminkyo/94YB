require 'rails_helper'

RSpec.describe Api::V1::CashesController, type: :controller do

  describe '#cash_list' do
    # header
    before(:each) do
      @user = create(:user, :with_token, :with_member_role)
      @wallet = create(:wallet)
      init_header
    end

    context 'before_action 검증' do
      it 'set_user_by_access_token 를 호출한다.' do
        expect_any_instance_of(ApplicationController).to receive(:set_user_by_access_token).once
        get :cash_list, params: @params
      end

      it "params에 accessToken이 없는 경우 status_code 401 오류와 message를 반환한다." do
        get :cash_list, params: {}
        expect(response.status).to eq Errors::UNAUTHORIZED_ERROR[0]
        body = Oj.load(response.body, symbol_keys: true)
        expect(body[:message]).to eq Errors::UNAUTHORIZED_ERROR[1]
      end

      it "params에 accessToken이 유효기간이 만료된 경우 status_code 401 오류와 message를 반환한다." do
        accessToken = TokenService.create_auth_token(Time.new(1994,10,21), @user, TokenService::TOKEN_TYPE::ACCESS_TOKEN, TokenService::TOKEN_EXPIRE::ACCESS_TOKEN)
        params = { accessToken: accessToken }
        get :cash_list, params: params
        expect(response.status).to eq Errors::UNAUTHORIZED_ERROR[0]
        body = Oj.load(response.body, symbol_keys: true)
        expect(body[:message]).to eq Errors::UNAUTHORIZED_ERROR[1]
      end

      it '요청한 user의 권한이 없는 경우, status_code 401 오류와 message를 반환한다.' do
        user = create(:user, :with_token)
        member_params = {}
        member_params[:accessToken] =TokenService.create_auth_token(Time.now, user, TokenService::TOKEN_TYPE::ACCESS_TOKEN, TokenService::TOKEN_EXPIRE::ACCESS_TOKEN)
        get :cash_list, params: member_params
        expect(response.status).to eq Errors::UNAUTHORIZED_ERROR[0]
        body = Oj.load(response.body, symbol_keys: true)
        expect(body[:message]).to eq Errors::UNAUTHORIZED_ERROR[1]
      end
    end

    context '정상케이스' do
      it 'status code 200을 반환한다.' do
        get :cash_list, params: @params
        expect(response.status).to eq 200
      end

      it 'response는 Hash 형태여야하며, total_page, total_cash, total_cash_update_at, cashes key가 존재해야한다.' do
        get :cash_list, params: @params
        expect(response.status).to eq 200
        body = Oj.load(response.body, symbol_keys: true)
        expect(body.kind_of? Hash).to eq true
        expect(body.key? :total_page).to eq true
        expect(body.key? :total_cash).to eq true
        expect(body.key? :total_cash_update_at).to eq true
        expect(body.key? :cashes).to eq true
      end

      it 'response의 cashes는 회비납부정보를 반환한다.' do
        cash1 = create(:cash, date:Time.now.strftime('%Y-%m-%d'), money: 20000, description: '', status: Cash::Status::INCOME, user_id:@user.id, current_money: 20000)
        cash2 = create(:cash, date:Time.now.strftime('%Y-%m-%d'), money: 30000, description: '', status: Cash::Status::INCOME, user_id:@user.id, current_money: 50000)
        cash3 = create(:cash, date:Time.now.strftime('%Y-%m-%d'), money: 40000, description: '', status: Cash::Status::INCOME, user_id:@user.id, current_money: 90000)
        get :cash_list, params: @params
        expect(response.status).to eq 200
        body = Oj.load(response.body, symbol_keys: true)
        cashes = body[:cashes]
        expect(cashes).to match(hash_including?(hash_including(response_cash_attributes(cash1, @user))))
        expect(cashes).to match(hash_including?(hash_including(response_cash_attributes(cash2, @user))))
        expect(cashes).to match(hash_including?(hash_including(response_cash_attributes(cash3, @user))))
      end
    end

    context '페이징' do
      before(:each) do
        (1..40).each do |i|
          if i == 40
            @cash1_1 = create(:cash, id: i, date:Time.now.strftime('%Y-%m-%d'), money: 10000 * i, description: '', status: Cash::Status::INCOME, user_id:@user.id, current_money: 0)
          elsif i == 39
            @cash1_2 = create(:cash, id: i, date:Time.now.strftime('%Y-%m-%d'), money: 10000 * i, description: '', status: Cash::Status::INCOME, user_id:@user.id, current_money: 0)
          elsif i == 20
            @cash2_1 = create(:cash, id: i, date:Time.now.strftime('%Y-%m-%d'), money: 10000 * i, description: '', status: Cash::Status::INCOME, user_id:@user.id, current_money: 0)
          elsif i == 19
            @cash2_2 = create(:cash, id: i, date:Time.now.strftime('%Y-%m-%d'), money: 10000 * i, description: '', status: Cash::Status::INCOME, user_id:@user.id, current_money: 0)
          else
            create(:cash, id: i, date:Time.now.strftime('%Y-%m-%d'), money: 10000 * i, description: '', status: Cash::Status::INCOME, user_id:@user.id, current_money: 0)
          end
        end
      end

      it 'page정보를 전달하지 않은 경우, 1페이지 정보를 전달한다.' do
        get :cash_list, params: @params
        expect(response.status).to eq 200
        body = Oj.load(response.body, symbol_keys: true)
        cashes = body[:cashes]

        expect(cashes[0][:id]).to eq @cash1_1.id
        expect(cashes[0][:money]).to eq @cash1_1.money
        expect(cashes[1][:id]).to eq @cash1_2.id
        expect(cashes[1][:money]).to eq @cash1_2.money
      end

      it 'page정보가 전달된 경우, 해당 페이지 정보를 전달한다.' do
        @params.merge!({ page: 2 })
        expect(response.status).to eq 200
        get :cash_list, params: @params
        body = Oj.load(response.body, symbol_keys: true)
        cashes = body[:cashes]

        expect(cashes[0][:id]).to eq @cash2_1.id
        expect(cashes[0][:money]).to eq @cash2_1.money
        expect(cashes[1][:id]).to eq @cash2_2.id
        expect(cashes[1][:money]).to eq @cash2_2.money
      end
    end

    context '에러 케이스' do
      it 'CashService#cashlist에서 nil을 반환할 때, 에러로그와 status 500과 에러 메시지를 반환해야한다.' do
        allow(CashService).to receive(:cash_list).and_return(nil)
        expect(Rails.logger).to receive(:warn).with(equal_exception?('cash list load fail'), any_args)

        get :cash_list, params: @params

        expect(response.status).to eq Errors::INTERNAL_SERVER_ERROR[0]

        body = Oj.load(response.body, symbol_keys: true)
        expect(body[:message]).to eq Errors::INTERNAL_SERVER_ERROR[1]
      end
    end
  end

  describe '#user_cash_list' do
    # header
    before(:each) do
      @user = create(:user, :with_token, :with_member_role)
      @wallet = create(:wallet)
      init_header
    end

    context 'before_action 검증' do
      it 'set_user_by_access_token 를 호출한다.' do
        expect_any_instance_of(ApplicationController).to receive(:set_user_by_access_token).once
        get :user_cash_list, params: @params
      end

      it "params에 accessToken이 없는 경우 status_code 401 오류와 message를 반환한다." do
        get :user_cash_list, params: {}
        expect(response.status).to eq Errors::UNAUTHORIZED_ERROR[0]
        body = Oj.load(response.body, symbol_keys: true)
        expect(body[:message]).to eq Errors::UNAUTHORIZED_ERROR[1]
      end

      it "params에 accessToken이 유효기간이 만료된 경우 status_code 401 오류와 message를 반환한다." do
        accessToken = TokenService.create_auth_token(Time.new(1994,10,21), @user, TokenService::TOKEN_TYPE::ACCESS_TOKEN, TokenService::TOKEN_EXPIRE::ACCESS_TOKEN)
        params = { accessToken: accessToken }
        get :user_cash_list, params: params
        expect(response.status).to eq Errors::UNAUTHORIZED_ERROR[0]
        body = Oj.load(response.body, symbol_keys: true)
        expect(body[:message]).to eq Errors::UNAUTHORIZED_ERROR[1]
      end

      it '요청한 user의 권한이 없는 경우, status_code 401 오류와 message를 반환한다.' do
        user = create(:user, :with_token)
        member_params = {}
        member_params[:accessToken] =TokenService.create_auth_token(Time.now, user, TokenService::TOKEN_TYPE::ACCESS_TOKEN, TokenService::TOKEN_EXPIRE::ACCESS_TOKEN)
        get :user_cash_list, params: member_params
        expect(response.status).to eq Errors::UNAUTHORIZED_ERROR[0]
        body = Oj.load(response.body, symbol_keys: true)
        expect(body[:message]).to eq Errors::UNAUTHORIZED_ERROR[1]
      end
    end

    context '정상케이스' do
      it 'status code 200을 반환한다.' do
        get :user_cash_list, params: @params
        expect(response.status).to eq 200
      end

      it 'response는 Hash 형태여야하며, total_page, cashes key가 존재해야한다.' do
        get :user_cash_list, params: @params
        expect(response.status).to eq 200
        body = Oj.load(response.body, symbol_keys: true)
        expect(body.kind_of? Hash).to eq true
        expect(body.key? :total_page).to eq true
        expect(body.key? :cashes).to eq true
      end

      it 'response의 cashes는 해당 user의 회비납부정보를 반환한다.' do
        cash1 = create(:cash, date:Time.now.strftime('%Y-%m-%d'), money: 20000, description: '', status: Cash::Status::INCOME, user_id:@user.id, current_money: 20000)
        cash2 = create(:cash, date:Time.now.strftime('%Y-%m-%d'), money: 30000, description: '', status: Cash::Status::INCOME, user_id:@user.id, current_money: 50000)

        other_user = create(:user, :with_token)
        create(:cash, date:Time.now.strftime('%Y-%m-%d'), money: 40000, description: '', status: Cash::Status::INCOME, user_id:other_user.id, current_money: 90000)
        create(:cash, date:Time.now.strftime('%Y-%m-%d'), money: 40000, description: '', status: Cash::Status::INCOME, user_id:other_user.id, current_money: 130000)

        get :user_cash_list, params: @params
        expect(response.status).to eq 200
        body = Oj.load(response.body, symbol_keys: true)
        cashes = body[:cashes]
        expect(cashes.size).to eq 2
        expect(cashes).to match(hash_including?(hash_including(response_cash_attributes(cash1, @user))))
        expect(cashes).to match(hash_including?(hash_including(response_cash_attributes(cash2, @user))))
      end
    end

    context '페이징' do
      before(:each) do
        other_user = create(:user, :with_token)

        (1..20).each do |i|
          if i == 20
            @cash2_1 = create(:cash, id: i, date:Time.now.strftime('%Y-%m-%d'), money: 10000 * i, description: '', status: Cash::Status::INCOME, user_id:@user.id, current_money: 0)
          elsif i == 19
            @cash2_2 = create(:cash, id: i, date:Time.now.strftime('%Y-%m-%d'), money: 10000 * i, description: '', status: Cash::Status::INCOME, user_id:@user.id, current_money: 0)
          else
            create(:cash, id: i, date:Time.now.strftime('%Y-%m-%d'), money: 10000 * i, description: '', status: Cash::Status::INCOME, user_id:@user.id, current_money: 0)
          end
        end

        (21..40).each do |i|
          if i == 40
            @other_cash_1 = create(:cash, id: i, date:Time.now.strftime('%Y-%m-%d'), money: 10000 * i, description: '', status: Cash::Status::INCOME, user_id:other_user.id, current_money: 0)
          elsif i == 39
            @other_cash_2 = create(:cash, id: i, date:Time.now.strftime('%Y-%m-%d'), money: 10000 * i, description: '', status: Cash::Status::INCOME, user_id:other_user.id, current_money: 0)
          else
            create(:cash, id: i, date:Time.now.strftime('%Y-%m-%d'), money: 10000 * i, description: '', status: Cash::Status::INCOME, user_id:other_user.id, current_money: 0)
          end
        end

        (41..60).each do |i|
          if i == 60
            @cash1_1 = create(:cash, id: i, date:Time.now.strftime('%Y-%m-%d'), money: 10000 * i, description: '', status: Cash::Status::INCOME, user_id:@user.id, current_money: 0)
          elsif i == 59
            @cash1_2 = create(:cash, id: i, date:Time.now.strftime('%Y-%m-%d'), money: 10000 * i, description: '', status: Cash::Status::INCOME, user_id:@user.id, current_money: 0)
          else
            create(:cash, id: i, date:Time.now.strftime('%Y-%m-%d'), money: 10000 * i, description: '', status: Cash::Status::INCOME, user_id:@user.id, current_money: 0)
          end
        end
      end

      it 'page정보를 전달하지 않은 경우, 1페이지 정보를 전달한다.' do
        get :user_cash_list, params: @params
        expect(response.status).to eq 200
        body = Oj.load(response.body, symbol_keys: true)
        cashes = body[:cashes]

        expect(cashes[0][:id]).to eq @cash1_1.id
        expect(cashes[0][:money]).to eq @cash1_1.money
        expect(cashes[1][:id]).to eq @cash1_2.id
        expect(cashes[1][:money]).to eq @cash1_2.money
      end

      it 'page정보가 전달된 경우, 해당 페이지 정보를 전달한다.' do
        @params.merge!({ page: 2 })
        expect(response.status).to eq 200
        get :user_cash_list, params: @params
        body = Oj.load(response.body, symbol_keys: true)
        cashes = body[:cashes]

        expect(cashes[0][:id]).to eq @cash2_1.id
        expect(cashes[0][:money]).to eq @cash2_1.money
        expect(cashes[1][:id]).to eq @cash2_2.id
        expect(cashes[1][:money]).to eq @cash2_2.money
      end
    end

    context '에러 케이스' do
      it 'CashService#cashlist에서 nil을 반환할 때, 에러로그와 status 500과 에러 메시지를 반환해야한다.' do
        allow(CashService).to receive(:cash_list).and_return(nil)
        expect(Rails.logger).to receive(:warn).with(equal_exception?('cash list load fail'), any_args)

        get :cash_list, params: @params

        expect(response.status).to eq Errors::INTERNAL_SERVER_ERROR[0]

        body = Oj.load(response.body, symbol_keys: true)
        expect(body[:message]).to eq Errors::INTERNAL_SERVER_ERROR[1]
      end
    end
  end


end

def init_header
  # request.headers['X-G-AD-ID'] = 'b1756b75-05de-403d-beee-ec4e14b77eec'
  # request.headers['X-APP-CODE'] = 'a105fa1c-fa56-4911-9fb9-e550c1904a6d'
  @params = {}
  @params[:accessToken] =TokenService.create_auth_token(Time.now, @user, TokenService::TOKEN_TYPE::ACCESS_TOKEN, TokenService::TOKEN_EXPIRE::ACCESS_TOKEN)
end

def response_cash_attributes(cash, user)
  {
      id: cash.id,
      description: cash.description,
      money: cash.money,
      status: cash.status,
      date: cash.date,
      display_name: user.display_name
  }
end