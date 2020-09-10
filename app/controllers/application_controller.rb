class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include ::Modules::ErrorHandler
  include ::YbLoggers::LogEventCodes
  include ::YbErrors

  rescue_from Exception, :with => :std_exception_handler
  rescue_from ::YbErrors::Logic, with: :yb_errors_handler

  prepend_before_action :init_request_env_for_logging

  before_action :generate_transaction_id
  before_action :set_picture

  def set_picture
    images = Dir.glob('app/assets/images/*.jpg')
    @picture_num = images[Random.rand(images.size)].split('/').last
  end

  def set_user_by_access_token(token)
    log_options = { log_event_code: DECODE_ACCESS_TOKEN_ERROR }
    raise Unauthorized.new(log_options.merge({ log_message: 'token valid fail' })) unless TokenService.token_validation_check(token, TokenService::TOKEN_TYPE::ACCESS_TOKEN)
    payload = TokenService.decode_token(token)
    raise Unauthorized.new(log_options.merge({ log_message: 'payload not found' })) unless payload.present?

    @user = User.find_by_provider_and_email(payload[0]['email'], payload[0]['provider_uid'])
    raise BadRequest.new(log_options.merge({ log_message: 'user not found' })) unless @user.present?
  end

  def check_authenticate_member(user)
    log_options = { log_event_code: AUTHENTICATE_ERROR }
    raise Unauthorized.new(log_options.merge({ log_message: 'not authenticate_member', user_id: user.id })) unless user.is_member? || user.is_admin? || user.is_manager?
  end

  protected
  def generate_transaction_id
    Thread.current[:current_session] = SecureRandom.hex
  end

  def init_request_env_for_logging
    Rails.logger.bind_http_request_env(request)
  end
end
