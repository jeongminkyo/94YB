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
                notices.created_at as created_at,
                notice_attachments.s3 as s3
                ')
          .joins('JOIN users ON users.id = notices.user_id')
          .joins('LEFT JOIN notice_attachments ON notices.id = notice_attachments.notice_id')
          .order('notices.id DESC').page(page).per(LIST_PER_PAGE)
    end
  end
end
