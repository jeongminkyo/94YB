module ServiceErrorHandler
  include ::YbErrors
  include ::YbLoggers::LogEventCodes

  def internal_server_error(error, log_options, log_message = '', log_level: :warn)
    InternalServer.new(log_options.merge({ log_message:log_message, log_level: log_level }), error: error)
  end

  def not_found_error(log_options, log_message = '', log_level: :warn)
    NotFound.new(log_options.merge({ log_message:log_message, log_level: log_level }))
  end

  def internal_error_with_invalid_params(log_options, log_message = '', log_level: :warn)
    internal_server_error(Errors::INVALID_SERVICE_PARAMETER, log_options, log_message, log_level: log_level)
  end

  def internal_error_with_validation_fail(log_options, log_message = '', log_level: :warn)
    internal_server_error(Errors::VALIDATION_FAILED, log_options, log_message, log_level: log_level)
  end

  def internal_error(log_options, log_message = '', log_level: :warn)
    internal_server_error(Errors::INTERNAL_SERVER_ERROR, log_options, log_message, log_level: log_level)
  end

  def error_message_from_exception(e)
    if e.kind_of?(YbErrors::Logic) && e.respond_to?(:log_message)
      "#{(e.log_message.presence || e.message)}"
    else
      "#{e.message}"
    end
  end
end