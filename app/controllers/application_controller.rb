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

  protected
  def generate_transaction_id
    Thread.current[:current_session] = SecureRandom.hex
  end

  def init_request_env_for_logging
    Rails.logger.bind_http_request_env(request)
  end
end
