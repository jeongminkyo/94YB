class IdentityFactory
  FactoryBot.define do
    factory :identity, class: Identity do
      provider { 'google_oauth2' }
    end
  end
end