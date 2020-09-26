class NoticeFactory
  FactoryBot.define do
    factory :notice, class: Notice do
      title { 'title' }
      context { 'context' }

      trait :with_attachments do
        after(:create) do |notice|
          create(:notice_attachment, notice_id: notice.id)
        end
      end
    end
  end
end