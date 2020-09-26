require 'rails_helper'

RSpec.describe Api::V1::NoticesController, type: :controller do

  describe '#notice_list' do
    # header
    before(:each) do
      @user = create(:user, :with_token, :with_member_role)
      @wallet = create(:wallet)
      @params = {}
      init_header
    end

    context 'before_action 검증' do
      it 'set_user_by_access_token 를 호출한다.' do
        expect_any_instance_of(ApplicationController).to receive(:set_user_by_access_token).once
        get :notice_list, params: @params
      end

      it "header에 accessToken이 없는 경우 status_code 401 오류와 message를 반환한다." do
        request.headers['X-YB-ACCESS-TOKEN'] = nil
        get :notice_list, params: {}
        expect(response.status).to eq Errors::UNAUTHORIZED_ERROR[0]
        body = Oj.load(response.body, symbol_keys: true)
        expect(body[:message]).to eq Errors::UNAUTHORIZED_ERROR[1]
      end

      it "params에 accessToken이 유효기간이 만료된 경우 status_code 401 오류와 message를 반환한다." do
        accessToken = TokenService.create_auth_token(Time.new(1994,10,21), @user, TokenService::TOKEN_TYPE::ACCESS_TOKEN, TokenService::TOKEN_EXPIRE::ACCESS_TOKEN)
        request.headers['X-YB-ACCESS-TOKEN'] = accessToken
        get :notice_list, params: {}
        expect(response.status).to eq Errors::UNAUTHORIZED_ERROR[0]
        body = Oj.load(response.body, symbol_keys: true)
        expect(body[:message]).to eq Errors::UNAUTHORIZED_ERROR[1]
      end

      it '요청한 user의 권한이 없는 경우, status_code 401 오류와 message를 반환한다.' do
        user = create(:user, :with_token)
        accessToken =TokenService.create_auth_token(Time.now, user, TokenService::TOKEN_TYPE::ACCESS_TOKEN, TokenService::TOKEN_EXPIRE::ACCESS_TOKEN)
        request.headers['X-YB-ACCESS-TOKEN'] = accessToken
        get :notice_list, params: {}
        expect(response.status).to eq Errors::UNAUTHORIZED_ERROR[0]
        body = Oj.load(response.body, symbol_keys: true)
        expect(body[:message]).to eq Errors::UNAUTHORIZED_ERROR[1]
      end
    end

    context '정상케이스' do
      it 'status code 200을 반환한다.' do
        get :notice_list, params: @params
        expect(response.status).to eq 200
      end

      it 'response는 Hash 형태여야하며, total_page, notices key가 존재해야한다.' do
        get :notice_list, params: @params
        expect(response.status).to eq 200
        body = Oj.load(response.body, symbol_keys: true)
        expect(body.kind_of? Hash).to eq true
        expect(body.key? :total_page).to eq true
        expect(body.key? :notices).to eq true
      end
    end

    context '에러 케이스' do
      it 'NoticeService#notice_list nil을 반환할 때, 에러로그와 status 500과 에러 메시지를 반환해야한다.' do
        allow(NoticeService).to receive(:notice_list).and_return(nil)
        expect(Rails.logger).to receive(:warn).with(equal_exception?('notice list load fail'), any_args)

        get :notice_list, params: @params

        expect(response.status).to eq Errors::INTERNAL_SERVER_ERROR[0]

        body = Oj.load(response.body, symbol_keys: true)
        expect(body[:message]).to eq Errors::INTERNAL_SERVER_ERROR[1]
      end
    end
  end
end

def init_header
  access_token = TokenService.create_auth_token(Time.now, @user, TokenService::TOKEN_TYPE::ACCESS_TOKEN, TokenService::TOKEN_EXPIRE::ACCESS_TOKEN)
  request.headers['X-YB-ACCESS-TOKEN'] = access_token
end