class Notice < ApplicationRecord
  resourcify
  include Authority::Abilities
  belongs_to :user
  has_many :notice_comments, dependent: :destroy
  has_many :notice_attachments
  has_many :notice_likes
  accepts_nested_attributes_for :notice_attachments

  LIST_PER_PAGE = 20

  class << self

    def find_notice_list(page)
      Notice.select('
                notices.id as id,
                notices.title as title,
                notices.context as context,
                notices.user_id as user_id,
                users.display_name as display_name,
                notices.created_at as created_at
                ')
          .joins('JOIN users ON users.id = notices.user_id')
          .order('id DESC').page(page).per(LIST_PER_PAGE)
    end

    def notice_list(page)
      notices = self.select('
                notices.id as id,
                notices.title as title,
                notices.context as context,
                notices.user_id as user_id,
                users.display_name as display_name,
                notices.created_at as created_at
                ')
          .joins('JOIN users ON users.id = notices.user_id')
          .group('notices.id')
          .order('notices.id DESC').page(page).per(LIST_PER_PAGE).as_json(include: :notice_attachments)

      notices.each do |notice|
        notice['created_at'] = notice['created_at'].strftime('%Y-%m-%d %H:%M:%S')
        new_attachments = []
        notice['notice_attachments'].each do |attachment|
          url = attachment['s3'].url
          new_data = { id: attachment['id'], url: url }
          new_attachments.push(new_data)
        end
        notice.except!('notice_attachments')
        notice['attachments'] = new_attachments
      end
    end
  end
end
