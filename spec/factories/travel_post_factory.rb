class TravelPostFactory
  FactoryBot.define do
    factory :travel_post, class: TravelPost do
      title { 'title' }
      context { 'context' }

      trait :with_attachments do
        after(:create) do |travel_post|
          create(:travel_post_attachment, travel_post_id: travel_post.id)
        end
      end
    end
  end
end