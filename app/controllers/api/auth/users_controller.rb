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

    def token_renewal
      log_options = { log_event_code: TOKEN_RENEWAL_ERROR }
      raise InvalidParameter.new(log_options.merge({ log_message: 'refreshToken is nil' })) unless params[:refreshToken].present?

      result = AuthService.renewal_token(params[:refreshToken])
      raise InternalServer.new(log_options.merge({ log_message: 'token renewal fail' })) unless result.present?

      render yb: result, status: :ok
    end
  end
end