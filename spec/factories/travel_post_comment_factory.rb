class TravelPostCommentFactory
  FactoryBot.define do
    factory :travel_comment, class: TravelComment do
      body { 'test' }
    end
  end
end