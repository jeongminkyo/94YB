module TokenService
  KEY = ENV['token_key']
  ALG_HS256 = 'HS256'

  module TOKEN_TYPE
    ACCESS_TOKEN = 0
    REFRESH_TOKEN = 1
  end

  module TOKEN_EXPIRE
    ACCESS_TOKEN = 2.hours
    REFRESH_TOKEN = 6.months
  end

  ISS = 'yb94'

  class << self
    def token_validation_check(token, token_type)
      require 'hashie'
      decode_token = decode_token(token)
      return false unless decode_token.present?
      token_obj = decode_token[0]
      token_info_hash = Hashie::Mash.new(token_obj)

      # 토큰 정보가 없으면 인증에러
      return false if token_obj.blank?

      # 토큰의 expire date가 오늘이전이면 인증에러
      token_expire_date = Time.at(token_info_hash.exp).to_datetime
      return false if token_expire_date < Time.now

      # 토큰정보에 들어간 타입이 요청한 토큰 타입과 다르면 인증 에러
      return false if token_info_hash.token_type != token_type

      true
    rescue => e
      additional_infos = { token: token, decode_token: token_obj }
      Rails.logger.warn(e, nil, additional_infos, ::YbLoggers::LogEventCodes::VALID_TOKEN_ERROR)
      false
    end

    def token_expire_in_two_month?(token)
      token_expire_date = Time.at(token['exp']).to_datetime
      return true if token_expire_date < Time.now + 2.months

      false
    rescue => e
      additional_infos = { token: token }
      Rails.logger.warn(e, nil, additional_infos, ::YbLoggers::LogEventCodes::VALID_TOKEN_ERROR)
      raise e
    end

    def create_auth_token(current_time, user, token_type, expire)
      payload = _set_payload_claim(user, token_type)

      expire_date = current_time + expire
      registered_claim = _set_registered_claim(expire_date.to_i, ISS)

      payload = payload.merge(registered_claim) if payload.present?
      token = JWT.encode payload, KEY, ALG_HS256
      token
    rescue => e
      additional_info = { message: e.to_s }
      Rails.logger.warn(e, nil, additional_info, ::YbLoggers::LogEventCodes::VALID_TOKEN_ERROR)
      nil
    end

    def decode_token(token)
      begin
        JWT.decode token, KEY, true, { :algorithm => ALG_HS256 }
      rescue JWT::ExpiredSignature => e
        additional_info = { message: e.to_s }
        Rails.logger.force_info('token is expired', nil, additional_info, ::YbLoggers::LogEventCodes::TOKEN_IS_EXPIRED)
        nil
      end
    end

    protected

    def _set_payload_claim(user, token_type)
      identity = Identity.find_by_user_id(user.id)
      provider = identity.present? ? identity.provider : nil
      {
          'email' => user.email,
          'display_name' => user.display_name,
          'provider_uid' => provider,
          'token_type' => token_type
      }
    end

    def _set_registered_claim(exp = nil, iss = nil, aud = nil, sub = nil, nbf = nil, lat = nil, jti = nil)
      registered_claim = {}
      registered_claim['exp'] = exp if exp.present?
      registered_claim['iss'] = iss if iss.present?
      registered_claim['aud'] = aud if aud.present?
      registered_claim['sub'] = sub if sub.present?
      registered_claim['nbf'] = nbf if nbf.present?
      registered_claim['lat'] = lat if lat.present?
      registered_claim['jti'] = jti if jti.present?
      registered_claim
    end
  end
end