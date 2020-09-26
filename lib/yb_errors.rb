module YbErrors
  class Logic < StandardError
    attr_reader :http_status_code, :code, :message, :additional_infos, :log_message, :log_event_code, :log_infos, :log_level

    def initialize(options, error: Errors::INTERNAL_SERVER_ERROR)
      initialize_helper(error, :bad_request, options)
    end

    def initialize_helper(error, http_status_code, options = {})
      @code = error[0].presence || Rack::Utils.status_code(http_status_code)
      @message = error[1].presence || convert_class_name_to_error_message
      @http_status_code = http_status_code
      @log_event_code = options.fetch(:log_event_code, nil)
      @log_message = options.fetch(:log_message, nil)
      @log_infos = options.fetch(:log_infos, nil)
      @log_level = options.fetch(:log_level, :warn)
      @additional_infos = options.except!(:code, :message, :log_event_code, :log_message, :log_infos, :log_level)
    end

    def convert_class_name_to_error_message
      self.class.name.split('::').last.underscore.gsub('_', ' ')
    end
  end

  # 모든 로직 에러는 기본 적으로 400(bad request) 에러로 반환한다.
  class BadRequest < Logic
    def initialize(options, error: Errors::BAD_REQUEST)
      initialize_helper(error, :bad_request, options)
    end
  end

  class NotFound < Logic
    def initialize(options, error: Errors::NOT_FOUND)
      initialize_helper(error, :not_found, options)
    end
  end

  # 컨트롤러 진입 시 잘못된 파라미터로 요청한 경우(400)
  class InvalidParameter < Logic
    def initialize(options, error: Errors::INVALID_PARAMETER)
      initialize_helper(error, :bad_request, options)
    end
  end

  # 컨트롤러 진입 시 로그인 에러(401)
  class Unauthorized < Logic
    def initialize(options, error: Errors::UNAUTHORIZED_ERROR)
      initialize_helper(error, :unauthorized, options)
    end
  end

  # 컨트롤러 진입 시 권한 에러(403)
  class Forbidden < Logic
    def initialize(options, error: Errors::FORBIDDEN)
      initialize_helper(error, :forbidden, options)
    end
  end

  class InternalServer < Logic
    def initialize(options, error: Errors::INTERNAL_SERVER_ERROR)
      initialize_helper(error, :internal_server_error, options)
    end
  end
end