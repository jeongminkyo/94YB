class UserFactory
  FactoryBot.define do
    factory :user, class: User do
      email { Faker::Internet.email }
      password { Devise.friendly_token[0,20] }
      color { '#123123' }
      display_name { Faker::Name.first_name }
      created_at { Time.now }
      updated_at { Time.now }

      after(:create) do |user|
        user.add_role(:user)
        create(:identity, user_id: user.id, uid: rand(10000))
      end

      trait :with_token do
        after(:create) do |user|
          refresh_token = TokenService.create_auth_token(Time.now, user, TokenService::TOKEN_TYPE::REFRESH_TOKEN, TokenService::TOKEN_EXPIRE::REFRESH_TOKEN)
          create(:user_token, user_id: user.id, refresh_token: refresh_token)
        end
      end

      trait :with_member_role do
        after(:create) do |user|
          user.add_role(:member)
        end
      end
    end
  end
end