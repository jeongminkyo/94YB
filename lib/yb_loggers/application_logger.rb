require 'rails'
require 'logger'
require 'oj'

class YbLoggers::ApplicationLogger
  LOGGER_VERSION = 0.2
  LOG_PREFIX = "#std_logger="
  LOG_LEVEL_DEBUG = 0
  LOG_LEVEL_INFO = 1
  LOG_LEVEL_WARN = 2
  LOG_LEVEL_ERROR = 3
  LOG_LEVEL_FATAL = 4
  APPLICATION_LOG_FILE = "log/application-#{Rails.env}.log"

  @hostname = nil
  @logger = nil
  @file_path = nil
  @current_log_level = LOG_LEVEL_INFO
  @is_using_color_formatter = true
  @http_request_env = nil

  def initialize(log_level = LOG_LEVEL_INFO, file_path = APPLICATION_LOG_FILE)
    @current_log_level = log_level
    @file_path = file_path
  end

  def bind_http_request_env(request)
    @http_request_env = HttpRequestEnv.new(request)
  end

  def _get_logger_instance
    if @logger.nil?
      @logger = Logger.new(@file_path)
      @logger.formatter = Formatter.new(true)
    end
    @logger
  end

  def formatter
    _get_logger_instance.formatter
  end

  def level
    @current_log_level
  end

  # Logger Appender
  #
  # NOTE: 로그를 남기기 위한 형태는 https://wiki.nbt.com/x/2WwSAQ 위키 참조
  #
  # #@param log_level [ Logger:ERROR  | Logger::WARN ]
  # @param String/Exception exception 로그 메시지 or Exception Object
  # @param Hash params Caller Method가 실행될때의 params 정보 (Controller인 경우 params, method인 경우 method의 params 전달)
  # @param Hash additional_infos 디버깅을 위해 Caller가 실행되기 위한 추가적인 정보 (ex. UserID, UserIP, ...)
  def append(log_level, exception = nil, params = nil, additional_infos = nil, event_code = nil)
    logger = _get_logger_instance

    # Rails의 실행 경로 확인
    rails_path = "#{Dir.pwd}/"
    if exception.is_a?(Exception)
      if exception.respond_to?(:log_message)
        message = exception.log_message.presence || exception.message.to_s
      else
        message = exception.message.to_s
      end

      target_backtrace = exception.backtrace
    else
      message = exception.to_s
      target_backtrace = caller
    end

    # Backtrace에서 직접 개발한 소스만 추출
    self_class = self.to_s.underscore
    interesting_backtrace = []
    target_backtrace.each do |file|
      if file.include?(rails_path) &&
          !file.include?(self_class) && !file.include?('std_exception_handler') && !file.include?("`/'")

        interesting_backtrace.push file.gsub rails_path, ''
      end
    end

    # 마지막에 실행된 소스 정보 추출
    matches = []
    names = []
    begin
      pattern = /(?<class>.*)\.rb:(?<line>\d+):in `((?<log_type>.*) in )?(?<method>.*)'/i
      matches = pattern.match(interesting_backtrace.first)
      names = matches.names
    rescue
    end

    location = {}
    offset = 1
    names.each do |key|
      value = matches[offset].to_s
      value = value.split('/').last.classify if key == 'class'

      location[key.to_sym] = value
      offset += 1
    end

    # Controller가 아닌 Model에서 Logging하는 경우 추적하기 위한 기본 정보 초기화
    unless @http_request_env.nil?
      params = @http_request_env.fetch('filtered_parameters') if params.nil?
      additional_infos = {} if additional_infos.nil?

      additional_infos[:req_path] = @http_request_env.fetch('req_path').presence || @http_request_env.fetch('path_info') if additional_infos[:req_path].blank?
      additional_infos[:req_method] = @http_request_env.fetch('req_method') if additional_infos[:req_method].blank?
      additional_infos[:req_remote_ip] = @http_request_env.fetch('req_remote_ip') if additional_infos[:req_remote_ip].blank?
      additional_infos[:remote_ip] = @http_request_env.req_client_ip if additional_infos[:remote_ip].blank?
      additional_infos[:client_ip] = @http_request_env.fetch('header_client_ip') if additional_infos[:client_ip].blank?
      additional_infos[:x_forwarded_for] = @http_request_env.fetch('header_x_forwarded_for') if additional_infos[:x_forwarded_for].blank?
      additional_infos[:exception_type] = exception.class.to_s || nil if additional_infos[:exception_type].blank?
      additional_infos[:req_headers] = @http_request_env.headers if additional_infos[:req_headers].blank?
      additional_infos[:transaction_id] = Thread.current[:current_session]
      additional_infos[:server_time] = (Time.now.to_f * 1000).to_i
    end

    unless params.nil?
      if location[:class] == params.fetch(:controller, '')
        location[:class] = params.fetch(:controller, '')
        location[:method] = params.fetch(:action, '')
      end
    end

    @hostname ||= ENV['HOST'] || `hostname`.strip

    # Password 제거
    params = hide_password(params)
    # 길이가 너무 긴 파라미터가 로그에 남으면 나중에 logstash 가 해당 line 을 가져갈 때 에러가 나서 logstash 가 죽어버림.
    # 에러로그 예 : #<Class:0x77bc2e16>: One or more parameters are invalid. Reason: Message must be shorter than 262144 bytes.
    params.delete_if { |_, value| value.to_s.length > 100000 } if params.present?

    additional_infos = hide_password(additional_infos)

    # Log에 기록할 메시지 생성
    message = { message: message,
                trace: { break_point: "#{location[:class]}##{location[:method]}:#{location[:line]}",
                         params: params,
                         additional_infos: additional_infos },
                event_code: event_code,
                log_level: log_level_to_s(log_level),
                backtrace: interesting_backtrace,
                timestamp: Time.now,
                server_node: @hostname,
                version: LOGGER_VERSION.to_s }

    begin
      json_str = Oj.dump(message, { indent: 0, mode: :compat })
    rescue Encoding::UndefinedConversionError
      json_str = Oj.dump(message, escape_mode: :ascii, symbol_keys: true)
    rescue
      json_str = message.to_json
    end

    log = json_str.to_s

    case log_level
    when LOG_LEVEL_FATAL
      logger.fatal log
    when LOG_LEVEL_ERROR
      logger.error log
    when LOG_LEVEL_WARN
      logger.warn log
    when LOG_LEVEL_INFO
      logger.info log
    when LOG_LEVEL_DEBUG
      logger.debug log
    else
      logger.error log
    end

  rescue => e
    logger.error "#{self} Exception: #{e.message} Backtrace: #{e.backtrace}"
  end

  # DEBUG 메시지 로깅
  def debug(msg = nil, params = nil, additional_info_args = {}, event_code = nil)
    return unless @current_log_level <= LOG_LEVEL_DEBUG

    append(LOG_LEVEL_DEBUG, msg, params, additional_info_args, event_code)
  end

  # INFO 메시지 로깅
  def info(msg = nil, params = nil, additional_info_args = {}, event_code = nil)
    return unless @current_log_level <= LOG_LEVEL_INFO

    msg = yield if block_given?
    append(LOG_LEVEL_INFO, msg, params, additional_info_args, event_code)
  end

  # LOG_LEVEL 과 상관없이 INFO 메시지 로깅
  def force_info(msg = nil, params = nil, additional_info_args = {}, event_code = nil)
    msg = yield if block_given?
    append(LOG_LEVEL_INFO, msg, params, additional_info_args, event_code)
  end

  # WARN 메시지 로깅
  def warn(msg = nil, params = nil, additional_info_args = {}, event_code = nil)
    return unless @current_log_level <= LOG_LEVEL_WARN

    msg = yield if block_given?
    append(LOG_LEVEL_WARN, msg, params, additional_info_args, event_code)
  end

  # ERROR 메시지 로깅
  def error(msg = nil, params = nil, additional_info_args = {}, event_code = nil)
    return unless @current_log_level <= LOG_LEVEL_ERROR

    msg = yield if block_given?
    append(LOG_LEVEL_ERROR, msg, params, additional_info_args, event_code)
  end

  # FATAL 메시지 로깅
  def fatal(msg = nil, params = nil, additional_info_args = {}, event_code = nil)
    return unless @current_log_level <= LOG_LEVEL_FATAL

    msg = yield if block_given?
    append(LOG_LEVEL_FATAL, msg, params, additional_info_args, event_code)
  end

  def level=(log_level)
    @current_log_level = log_level
  end

  def formatter=(formatter)
    _get_logger_instance.formatter = formatter
  end

  def use_color=(using_color)
    self.formatter = Formatter.new(using_color)
  end

  def debug?
    @current_log_level == LOG_LEVEL_DEBUG
  end

  def info?
    @current_log_level == LOG_LEVEL_INFO
  end

  def hide_password(msg_hash)
    return nil if msg_hash.nil?
    return msg_hash unless msg_hash.is_a?(Hash)

    new_hash = {}
    msg_hash.each do |key, value|
      if key.to_s.include?('password')
        new_hash.merge!({ key => '****' })
      else
        new_hash.merge!({ key => value })
      end
    end
    new_hash
  end

  # config.assets.quiet 가 true 일때 런타임 오류를 방지하기위해 추가.
  # config.assets.quiet 는 기본은 false 이고, true 일경우 silence 함수를 이용해서
  # 로그레벨을 error로 바꾸고 하위로직을 실행시킨다음에 로직이 끝나고 다시 원래 로그레벨로 복구하는 로직임.
  # ActiveSupport::Logger 에는 기본적으로 지원하나, 우리가 만든 로거와는 동작이 방식이 달라서(상속vs랩핑) silence 함수를 무시하게 처리함.
  # Sprockets::Rails::QuietAssets 참고, ActiveSupport::LoggerSilence 참고, ActiveSupport::LoggerThreadSafeLevel 참고
  def silence(_temporary_level = Logger::ERROR)
    yield
  end

  def log_level_to_s(log_level)
    case log_level
    when LOG_LEVEL_FATAL
      'fatal'
    when LOG_LEVEL_ERROR
      'error'
    when LOG_LEVEL_WARN
      'warn'
    when LOG_LEVEL_INFO
      'info'
    when LOG_LEVEL_DEBUG
      'debug'
    else
      'error'
    end
  end
end

# RoR ApplicationController의 request Object값 참조용
# 주로 request.env를 통해 값을 참조
class HttpRequestEnv
  @request = nil
  @allow_keys = nil
  @is_strict_mode = true # allow_keys로 정의된 값 참조만 허용하는 경우 true, request.env를 통해 참조 할 수 있는 모든 값의 참조를 허용 하는 경우 false

  def initialize(request, is_strict_mode = true)
    @is_strict_mode = is_strict_mode
    @request = request

    @allow_keys = { 'req_path' => 'REQUEST_PATH', # 요청된 URL에서 도메인을 제외한 URI 정보. ex) /tests. 유사 Key REQUEST_PATH, ORIGINAL_FULLPATH
                    'path_info' => 'PATH_INFO', # 요청된 URL에서 도메인을 제외한 URI 정보(req_path 가 nil일 경우 사용)
                    'req_querystring' => 'rack.request.query_string', # Request Params. ex) a=1&b=2
                    'req_remote_ip' => 'REMOTE_ADDR', # 요청 클라이언트 IP. Proxy등을 경유한 경우 서버와 최종 통신한 서버 IP. ex) 127.0.0.1
                    'req_method' => 'REQUEST_METHOD', # 요청 METHOD. ex) GET
                    'header_x_forwarded_for' => 'HTTP_X_FORWARDED_FOR', # 요청 클라이언트 IP. Proxy등을 경유한 경우 서버와 최종 통신한 서버 IP. ex) 127.0.0.1
                    'header_client_ip' => 'HTTP_CLIENT_IP', # 요청 클라이언트 IP. Proxy등을 경유한 경우 서버와 최종 통신한 서버 IP. ex) 127.0.0.1
                    'filtered_parameters' => 'action_dispatch.request.parameters', # Request Params + Action Params. ex)
                    'controller_action' => 'action_dispatch.request.path_parameters' } # controller#action
  end

  # HTTP Request 중 key 값 반환
  #
  # @params string key
  # @params string default_value key의 값이 없는 경우 반환 할 기본 값
  # @return mixed
  def fetch(key, default_value = '')
    return nil if @request.nil? || @request.env.nil?

    real_key = @allow_keys.fetch(key, nil)
    real_key = key if real_key.nil? && @is_strict_mode != true

    @request.env.fetch(real_key, default_value)
  end

  # HTTP Request Header 반환
  #
  # @return Hash
  def headers
    return nil if @request.nil? || @request.env.nil?

    tmp = {}
    ignore_headers = ['HTTP_ACCEPT']
    @request.env.each do |k, v|
      if k.start_with?('HTTP_') && !ignore_headers.include?(k)
        k = k[5, k.length].downcase
        tmp[k] = v
      end
    end

    # KEY로 정렬
    tmp_sorted = {}
    tmp.keys.sort.each do |k|
      tmp_sorted[k] = tmp[k]
    end
    tmp_sorted
  end

  # 클라이언트의 IP를 반환
  def req_client_ip
    client_ip = @request.remote_ip
    begin
      # HTTPS를 통해 ZONE1으로 유입되는 트래픽
      if @request.env['HTTP_X_FORWARDED_FOR'].present?
        client_ip = @request.env['HTTP_X_FORWARDED_FOR'].split(',').first
      end
    rescue
    end

    client_ip
  end
end

class Formatter
  SEVERITY_TO_TAG_MAP = { 'DEBUG' => 'debug', 'INFO' => 'info', 'WARN' => 'warn', 'ERROR' => 'error', 'FATAL' => 'fatal', 'UNKNOWN' => 'unknown' }
  SEVERITY_TO_COLOR_MAP = { 'DEBUG' => '0;37', 'INFO' => '32', 'WARN' => '33', 'ERROR' => '31', 'FATAL' => '31', 'UNKNOWN' => '37' }
  USE_HUMOROUS_SEVERITIES = true

  @is_using_color = false

  def initialize(use_color = false)
    @is_using_color = use_color
  end

  def call(severity, time, _progname, msg)
    return "#{msg.to_s.strip}\n" if Rails.env.production? || Rails.env.sandbox?

    # PRODUCTION, SANDBOX 환경이 아닐경우는 기존처럼 노출되게 한다.
    formatted_severity = if USE_HUMOROUS_SEVERITIES
                           format("%-3s", SEVERITY_TO_TAG_MAP[severity].to_s)
                         else
                           format("%-5s", severity.to_s)
                         end
    formatted_time = time.strftime("%Y-%m-%d %H:%M:%S.%L %z")
    color = SEVERITY_TO_COLOR_MAP[severity]

    if @is_using_color
      "[\033[0;37m#{Rails.application.class.parent_name}\033[0m] [\033[0;37m#{formatted_time}\033[0m] [\033[#{color}m#{formatted_severity}\033[0m] \033[#{color}m#{msg.to_s.strip}\033[0m\n"
    else
      "[#{Rails.application.class.parent_name}] [#{formatted_time}] [#{formatted_severity}] #{msg.to_s.strip}\n"
    end
  end
end