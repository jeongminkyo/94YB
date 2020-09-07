module Modules::ErrorHandler
  require 'resolv'

  def std_exception_handler(msg = nil, additional_infos = nil, log_level = Logger::ERROR)
    client_ip = request.env['HTTP_CLIENT_IP'] || nil
    x_forwarded_for = request.env['HTTP_X_FORWARDED_FOR'] || nil

    req_headers = {}
    request.env.each do |k, v|
      if k.start_with? 'HTTP_'
        k = k[5, k.length].downcase
        req_headers[k] = v
      end
    end
    remote_ip = req_client_ip # HTTP Call한 원격지 IP (실제 사용자IP일수도 있고 Gateway Server일수도 있음)

    a_infos = { req_method: request.method,
                req_remote_ip: request.remote_ip,
                remote_ip: remote_ip,
                client_ip: client_ip,                     # Proxy 경유 시
                x_forwarded_for: x_forwarded_for,         # Proxy 경유 시
                exception_type: msg.class.to_s || nil,    # msg가 Exception인 경우 Exception Type
                req_headers: req_headers }
    a_infos.delete_if { |_k, v| v.blank? }

    a_infos = a_infos.merge(additional_infos) unless additional_infos.nil?

    if log_level == Logger::ERROR
      Rails.logger.error(msg, params, a_infos)
    elsif log_level == Logger::WARN
      Rails.logger.warn(msg, params, a_infos)
    end

    if request[:action].to_s.downcase == 'not_found'
      render file: "#{Rails.root}/public/404", layout: false, status: :not_found
    elsif request.path.start_with?('/api/')
      render yb: nil, error: { code: Errors::INTERNAL_SERVER_ERROR[0], message: Errors::INTERNAL_SERVER_ERROR[1] }, status: :internal_server_error
    else
      render file: "#{Rails.root}/public/500", layout: false, status: :internal_server_error
    end
  end

  def yb_errors_handler(e)
    log_infos = e.log_infos.presence || {}
    additional_infos = e.additional_infos.presence || {}
    log_infos.merge!(additional_infos.except!(:log_infos))
    if e.respond_to?(:log_level)
      if e.log_level == :force_info
        Rails.logger.force_info(e, params, log_infos, e.log_event_code)
      elsif e.log_level == :error
        Rails.logger.error(e, params, log_infos, e.log_event_code)
      else
        Rails.logger.warn(e, params, log_infos, e.log_event_code)
      end
    else
      Rails.logger.warn(e, params, log_infos, e.log_event_code)
    end

    if request.path.start_with?('/api/')
      render yb: nil, error: { code: e.code, message: e.message }.merge!(e.additional_infos), status: e.http_status_code
    elsif e.code == Rack::Utils.status_code(:unauthorized)
      render file: "#{Rails.root}/public/401", layout: false, status: :unauthorized
    else
      render file: "#{Rails.root}/public/500", layout: false, status: :internal_server_error
    end
  end

  def req_client_ip
    client_ip = request.remote_ip
    begin
      if request.env['HTTP_X_FORWARDED_FOR'].present?
        client_ip = request.env['HTTP_X_FORWARDED_FOR'].split(',').first
      end
    rescue => e
      Rails.logger.warn("get request client ip error : #{e}")
    end
    client_ip
  end
end