class NoticeCommentFactory
  FactoryBot.define do
    factory :notice_comment, class: NoticeComment do
      body { 'test' }

    end
  end
end