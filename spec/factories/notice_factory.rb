class NoticeFactory
  FactoryBot.define do
    factory :notice, class: Notice do
      title { 'title' }
      context { 'context' }
    end
  end
end