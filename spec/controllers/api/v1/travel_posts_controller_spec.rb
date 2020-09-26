require 'rails_helper'

RSpec.describe Api::V1::TravelPostsController, type: :controller do

  describe '#travel_post_list' do
    # header
    before(:each) do
      @user = create(:user, :with_token, :with_member_role)
      @params = {}
      init_header
    end

    context 'before_action 검증' do
      it 'set_user_by_access_token 를 호출한다.' do
        expect_any_instance_of(ApplicationController).to receive(:set_user_by_access_token).once
        get :travel_post_list, params: @params
      end

      it "header에 accessToken이 없는 경우 status_code 401 오류와 message를 반환한다." do
        request.headers['X-YB-ACCESS-TOKEN'] = nil
        get :travel_post_list, params: {}
        expect(response.status).to eq Errors::UNAUTHORIZED_ERROR[0]
        body = Oj.load(response.body, symbol_keys: true)
        expect(body[:message]).to eq Errors::UNAUTHORIZED_ERROR[1]
      end

      it "params에 accessToken이 유효기간이 만료된 경우 status_code 401 오류와 message를 반환한다." do
        accessToken = TokenService.create_auth_token(Time.new(1994,10,21), @user, TokenService::TOKEN_TYPE::ACCESS_TOKEN, TokenService::TOKEN_EXPIRE::ACCESS_TOKEN)
        request.headers['X-YB-ACCESS-TOKEN'] = accessToken
        get :travel_post_list, params: {}
        expect(response.status).to eq Errors::UNAUTHORIZED_ERROR[0]
        body = Oj.load(response.body, symbol_keys: true)
        expect(body[:message]).to eq Errors::UNAUTHORIZED_ERROR[1]
      end

      it '요청한 user의 권한이 없는 경우, status_code 401 오류와 message를 반환한다.' do
        user = create(:user, :with_token)
        accessToken =TokenService.create_auth_token(Time.now, user, TokenService::TOKEN_TYPE::ACCESS_TOKEN, TokenService::TOKEN_EXPIRE::ACCESS_TOKEN)
        request.headers['X-YB-ACCESS-TOKEN'] = accessToken
        get :travel_post_list, params: {}
        expect(response.status).to eq Errors::UNAUTHORIZED_ERROR[0]
        body = Oj.load(response.body, symbol_keys: true)
        expect(body[:message]).to eq Errors::UNAUTHORIZED_ERROR[1]
      end
    end

    context '정상케이스' do
      it 'status code 200을 반환한다.' do
        get :travel_post_list, params: @params
        expect(response.status).to eq 200
      end

      it 'response는 Hash 형태여야하며, total_page, travel_posts key가 존재해야한다.' do
        get :travel_post_list, params: @params
        expect(response.status).to eq 200
        body = Oj.load(response.body, symbol_keys: true)
        expect(body.kind_of? Hash).to eq true
        expect(body.key? :total_page).to eq true
        expect(body.key? :travel_posts).to eq true
      end

      it 'response의 travel_posts는 여행정보를 반환한다.' do
        post1 = create(:travel_post, title:'test1', context: 'test1', user_id:@user.id)
        post2 = create(:travel_post, title:'test2', context: 'test2', user_id:@user.id)

        get :travel_post_list, params: @params
        expect(response.status).to eq 200
        body = Oj.load(response.body, symbol_keys: true)
        travel_posts = body[:travel_posts]
        expect(travel_posts).to match(hash_including?(hash_including(response_travel_post_attributes(post1, @user))))
        expect(travel_posts).to match(hash_including?(hash_including(response_travel_post_attributes(post2, @user))))
      end

      it 'response의 travel_posts의 댓글 정보가 있는 경우, 댓글 정보도 포함하여 반환한다.' do
        another_user = create(:user)
        post1 = create(:travel_post, title:'test1', context: 'test1', user_id:@user.id)
        comment1 = create(:travel_comment, body: 'comment body1', user_id: another_user.id, travel_post_id: post1.id)
        comment2 = create(:travel_comment, body: 'comment body2', user_id: another_user.id, travel_post_id: post1.id)

        get :travel_post_list, params: @params
        expect(response.status).to eq 200
        body = Oj.load(response.body, symbol_keys: true)
        travel_posts = body[:travel_posts]

        expect(travel_posts[0][:comments]).to match(hash_including?(hash_including(response_post_comment(comment1))))
        expect(travel_posts[0][:comments]).to match(hash_including?(hash_including(response_post_comment(comment2))))
      end
    end

    context '에러 케이스' do
      it 'NoticeService#notice_list nil을 반환할 때, 에러로그와 status 500과 에러 메시지를 반환해야한다.' do
        allow(TravelPostService).to receive(:travel_post_list).and_return(nil)
        expect(Rails.logger).to receive(:warn).with(equal_exception?('travel_post list load fail'), any_args)

        get :travel_post_list, params: @params

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

def response_travel_post_attributes(travel_post, user)
  {
      id: travel_post.id,
      title: travel_post.title,
      context: travel_post.context,
      created_at: travel_post.created_at.strftime('%Y-%m-%d %H:%M:%S'),
      display_name: user.display_name,
      attachments: [],
      comments: []
  }
end

def response_post_comment(comment)
  {
      id: comment['id'],
      content: comment['body'],
      display_name: User.find_by_id(comment.user_id)&.display_name,
      created_at: comment['created_at'].strftime('%Y-%m-%d %H:%M:%S')
  }
end