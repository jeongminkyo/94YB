class AuthService < ApplicationService
  class << self
    def social_sign_in(social_token, provider)
      log_options = { log_event_code: SOCIAL_SIGN_IN_ERROR }
      payload = decode_google_token(social_token)
      raise internal_error_with_validation_fail(log_options, 'payload not found', log_level: :warn) unless payload.present?

      user = exist_user?(payload['sub'], provider)
      if user.present?
        access_token = TokenService.create_auth_token(Time.now, user, TokenService::TOKEN_TYPE::ACCESS_TOKEN, TokenService::TOKEN_EXPIRE::ACCESS_TOKEN)
        if user.user_token.present?
          refresh_token = user.user_token.refresh_token
        else
          # Refresh Token 생성
          refresh_token = TokenService.create_auth_token(Time.now, user, TokenService::TOKEN_TYPE::REFRESH_TOKEN, TokenService::TOKEN_EXPIRE::REFRESH_TOKEN)
          raise 'refresh_token not found' if refresh_token.blank?

          user.build_user_token(
              refresh_token: refresh_token
          )
          user.save!
        end
      else
        access_token, refresh_token = [nil, nil]
      end

      {
          access_token: access_token,
          refresh_token: refresh_token,
          email: user.present? ? user.email : nil,
          display_name: user.present? ? user.display_name : nil
      }
    rescue => e
      Rails.logger.warn(e, {}, { social_token: social_token }, SOCIAL_SIGN_IN_ERROR)
      nil
    end

    def sign_up(social_token, provider)
      log_options = { log_event_code: SOCIAL_SIGN_UP_ERROR }
      payload = decode_google_token(social_token)
      raise internal_error_with_validation_fail(log_options, 'payload not found', log_level: :warn) unless payload.present?

      user = exist_user?(payload['sub'], provider)
      return raise internal_error_with_invalid_params(log_options, 'sign up user exist', log_level: :warn) if user.present?

      build_sign_up_user(payload, provider)
    rescue ::YbErrors::Logic => e
      raise e
    rescue => e
      Rails.logger.warn(e, {}, { social_token: social_token }, SOCIAL_SIGN_UP_ERROR)
      nil
    end

    def renewal_token(refresh_token)
      log_options = { log_event_code: TOKEN_RENEWAL_ERROR }

      user_token = UserToken.where(refresh_token: refresh_token).first
      return raise internal_error_with_invalid_params(log_options, 'user token not found', log_level: :warn) unless user_token.present?
      user = user_token.user
      return raise internal_error_with_invalid_params(log_options, 'user not found', log_level: :warn) unless user.present?

      decode_token = TokenService.decode_token(refresh_token)[0]

      if decode_token.present? && TokenService.token_expire_over_ten_days?(decode_token)
        new_refresh_token = nil
      else
        # Refresh Token 생성
        new_refresh_token = TokenService.create_auth_token(Time.now, user, TokenService::TOKEN_TYPE::REFRESH_TOKEN, TokenService::TOKEN_EXPIRE::REFRESH_TOKEN)
        raise internal_server_error(Errors::INTERNAL_SERVER_ERROR, log_options, 'refresh token not found', log_level: :warn) if refresh_token.blank?
        user_token.update_attributes!(refresh_token: new_refresh_token)
      end

      # Access_token 생성
      access_token = TokenService.create_auth_token(Time.now, user, TokenService::TOKEN_TYPE::ACCESS_TOKEN, TokenService::TOKEN_EXPIRE::ACCESS_TOKEN)
      raise internal_server_error(Errors::INTERNAL_SERVER_ERROR, log_options, 'access token not found', log_level: :warn) if access_token.blank?

      {
          access_token: access_token,
          refresh_token: new_refresh_token
      }
    rescue => e
      Rails.logger.warn(e, {}, { refresh_token: refresh_token }, TOKEN_RENEWAL_ERROR)
      nil
    end

    private

    def decode_google_token(token)
      validator = GoogleIDToken::Validator.new
      begin
        client_id = ENV['firebase_key']
        validator.check(token, client_id, nil)
      rescue GoogleIDToken::ValidationError => e
        Rails.logger.force_info(e, nil, { token: token }, SOCIAL_SIGN_IN_ERROR)
        nil
      end
    end

    def exist_user?(uid, provider)
      identity = Identity.where(uid: uid, provider: provider).first
      return nil unless identity.present?
      identity.user
    end

    def build_sign_up_user(payload, provider)
      color = Random.rand(255).to_s(16) + Random.rand(255).to_s(16) + Random.rand(255).to_s(16)
      user = User.new(
          email: payload['email'],
          password: Devise.friendly_token[0,20],
          color: '#' + color,
          display_name: payload['name']
      )

      user.build_identity(
          uid: payload['sub'],
          :provider => provider
      )

      # Access_token 생성
      access_token = TokenService.create_auth_token(Time.now, user, TokenService::TOKEN_TYPE::ACCESS_TOKEN, TokenService::TOKEN_EXPIRE::ACCESS_TOKEN)
      raise 'access token not found' if access_token.blank?

      # Refresh Token 생성
      refresh_token = TokenService.create_auth_token(Time.now, user, TokenService::TOKEN_TYPE::REFRESH_TOKEN, TokenService::TOKEN_EXPIRE::REFRESH_TOKEN)
      raise 'refresh_token not found' if refresh_token.blank?

      user.build_user_token(
          refresh_token: refresh_token
      )
      user.save!

      {
          access_token: access_token,
          refresh_token: refresh_token
      }
    end
  end
end