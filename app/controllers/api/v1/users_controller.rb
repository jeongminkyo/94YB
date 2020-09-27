module Api::V1
  class UsersController < ApplicationController

    skip_before_action :verify_authenticity_token
    prepend_before_action only: [:upsert_push_token] do
      set_user_by_access_token(request.headers['X-YB-ACCESS-TOKEN'])
    end

    # GET /api/v1/user_list
    def user_list
      users = User.user_list

      render json: users
    end

    def upsert_push_token
      log_options = { log_event_code: PUSH_TOKEN_ERROR }
      raise InvalidParameter.new(log_options.merge({ log_message: 'pushToken is nil' })) unless params[:pushToken].present?

      result = @user.upsert_push_token(params[:pushToken])
      raise InternalServer.new(log_options.merge({ log_message: 'push token upsert fail' })) unless result.present?

      render yb: {}, status: :ok
    end
  end
end