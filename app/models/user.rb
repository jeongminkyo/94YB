class User < ApplicationRecord
  rolify
  include Authority::UserAbilities
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :post
  has_many :post_likes
  has_many :comments
  has_many :travel_posts
  has_many :travel_post_likes
  has_many :travel_comments
  has_many :notices
  has_many :notice_likes
  has_many :notice_comments
  has_many :cashes
  has_one :user_token
  has_one :identity

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  after_create :set_default_role

  # email이 없어도 가입이 되도록 설정

  def email_required?
    false
  end

  def is_admin?
    has_role?(:admin)
  end

  def is_user?
    has_role?(:user)
  end

  def is_member?
    has_role?(:member)
  end

  def is_manager?
    has_role?(:manager)
  end

  def upsert_push_token(push_token)
    self.user_token&.update_attributes!(push_token: push_token)
  rescue => e
    Rails.logger.warn(e, {}, { push_token: push_token }, ::YbLoggers::LogEventCodes::PUSH_TOKEN_ERROR)
    nil
  end

  def update_refresh_token(refresh_token)
    self.user_token&.update_attributes!(refresh_token: refresh_token)
  rescue => e
    Rails.logger.warn(e, {}, { refresh_token: refresh_token }, ::YbLoggers::LogEventCodes::PUSH_TOKEN_ERROR)
    nil
  end

  class << self
    def find_for_oauth(auth, signed_in_resource = nil)
      # user와 identity가 nil이 아니라면 받는다
      identity = Identity.find_for_oauth(auth)
      user = signed_in_resource ? signed_in_resource : identity.user

      # user가 nil이라면 새로 만든다.
      if user.nil?
        # 이미 있는 이메일인지 확인한다.
        email = auth.info.email
        user = User.where(:email => email).first
        unless self.where(email: auth.info.email).exists?
          # 없다면 새로운 데이터를 생성한다.
          if user.nil?
            color = Random.rand(255).to_s(16) + Random.rand(255).to_s(16) + Random.rand(255).to_s(16)
            user = User.new(
                email: auth.info.email,
                password: Devise.friendly_token[0,20],
                color: '#' + color
            )
            user.save!
          end
        end
      end

      if identity.user != user
        identity.user = user
        identity.save!
      end
      user
    end

    def user_list
      self.select('id, display_name').all
    end

    def find_by_provider_and_email(email, provider)
      User.joins(:identity).where('email =? and provider = ?', email, provider).first
    end
  end

  private

  def set_default_role
    add_role :user
  end

end
