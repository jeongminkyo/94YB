module Api::Auth
  class UsersController < ApplicationController

    skip_before_action :verify_authenticity_token

    def sign_in
      log_options = { log_event_code: SOCIAL_SIGN_IN_ERROR }
      raise InvalidParameter.new(log_options.merge({ log_message: 'idToken is nil' })) unless params[:idToken].present?
      raise InvalidParameter.new(log_options.merge({ log_message: 'provider is nil' })) unless params[:provider].present?

      result = AuthService.social_sign_in(params[:idToken], params[:provider])
      raise InternalServer.new(log_options.merge({ log_message: 'social_sign_in not found' })) unless result.present?

      render yb:result, status: :ok
    end

    def sign_up
      log_options = { log_event_code: SOCIAL_SIGN_IN_ERROR }
      raise InvalidParameter.new(log_options.merge({ log_message: 'idToken is nil' })) unless params[:idToken].present?
      raise InvalidParameter.new(log_options.merge({ log_message: 'provider is nil' })) unless params[:provider].present?

      result = AuthService.sign_up(params[:idToken], params[:provider])

      render yb: result, status: :ok
    end

    def acceess_token_renewal(refresh_token)
    end

    def me
      log_options = { log_event_code: SOCIAL_SIGN_IN_ERROR }
      raise InvalidParameter.new(log_options.merge({ log_message: 'access_token is nil' })) unless params[:accessToken].present?

      result = AuthService.me(params[:accessToken])
      raise InternalServer.new(log_options.merge({ log_message: 'me user not found' })) unless result.present?

      render yb: result, status: :ok
    end
  end
end