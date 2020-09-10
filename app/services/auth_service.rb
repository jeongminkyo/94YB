class AuthService < ApplicationService
  class << self
    def social_sign_in(social_token, provider)
      payload = decode_google_token(social_token)
      raise 'payload not found' unless payload.present?

      user = exist_user?(payload['sub'], provider)
      if user.present?
        access_token = TokenService.create_auth_token(Time.now, user, TokenService::TOKEN_TYPE::ACCESS_TOKEN, TokenService::TOKEN_EXPIRE::ACCESS_TOKEN)
        refresh_token = user.user_token.refresh_token
      else
        access_token, refresh_token = [nil, nil]
      end

      {
          access_token: access_token,
          refresh_token: refresh_token,
          email: user.email,
          display_name: user.display_name
      }
    rescue => e
      Rails.logger.warn(e, {}, { social_token: social_token }, SOCIAL_SIGN_IN_ERROR)
      nil
    end

    def sign_up(social_token, provider)
      payload = decode_google_token(social_token)
      raise 'payload not found' unless payload.present?

      user = exist_user?(payload['sub'], provider)
      return raise 'sign up user exist' if user.present?

      build_sign_up_user(payload, provider)
    rescue => e
      Rails.logger.warn(e, {}, { social_token: social_token }, SOCIAL_SIGN_IN_ERROR)
      nil
    end

    def me(access_token)
      raise 'access_token not valid' unless TokenService.token_validation_check(access_token, TokenService::TOKEN_TYPE::ACCESS_TOKEN)
      payload = TokenService.decode_token(access_token)
      raise 'payload not found' unless payload.present?

      user = User.find_by_provider_and_email(payload[0]['email'], payload[0]['provider_uid'])
      return raise 'user not found' unless user.present?

      {
          email: user.email,
          display_name: user.display_name
      }
    rescue => e
      Rails.logger.warn(e, {}, { access_token: access_token }, SOCIAL_SIGN_IN_ERROR)
      nil
    end

    private

    def decode_google_token(token)
      validator = GoogleIDToken::Validator.new
      begin
        client_id = '549726225147-kdms2e2qf2tfvdhh2l49e5ao6447c3hq.apps.googleusercontent.com'
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
      user = User.new(params[:user])
      user.build_identity(
          uid: payload['sub'],
          :provider => provider
      )

      user.save!

      # Access_token 생성
      access_token = TokenService.create_auth_token(Time.now, user, TokenService::TOKEN_TYPE::ACCESS_TOKEN, TokenService::TOKEN_EXPIRE::ACCESS_TOKEN)
      raise 'access token not found' if access_token.blank?

      # Refresh Token 생성
      refresh_token = TokenService.create_auth_token(Time.now, user, TokenService::TOKEN_TYPE::REFRESH_TOKEN, TokenService::TOKEN_EXPIRE::REFRESH_TOKEN)
      raise 'refresh_token not found' if refresh_token.blank?

      {
          access_token: access_token,
          refresh_token: refresh_token
      }
    end
  end
end