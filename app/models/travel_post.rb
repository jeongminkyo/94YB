class TravelPost < ApplicationRecord
  resourcify
  include Authority::Abilities
  belongs_to :user
  has_many :travel_comments, dependent: :destroy
  has_many :travel_post_attachments
  has_many :travel_post_likes
  accepts_nested_attributes_for :travel_post_attachments

  LIST_PER_PAGE = 20

  class << self

    def find_travel_post_list(page, where_clause)
      TravelPost.select('
                travel_posts.id as id,
                travel_posts.title as title,
                travel_posts.context as context,
                travel_posts.user_id as user_id,
                users.display_name as display_name,
                travel_posts.created_at as created_at
                ')
                .where(where_clause)
                .joins('JOIN users ON users.id = travel_posts.user_id')
                .order('travel_posts.id DESC').page(page).per(LIST_PER_PAGE)
    end

    def make_where_clause(params)
      return '' if params[:search_by].blank? && params[:search_value].blank?

      search_by = params[:search_by].blank? ? nil : params[:search_by]
      search_value = params[:search_value].blank? ? nil : params[:search_value]
      where_clause = ''

      # key, value 기준 검색 where 조건 생성
      if search_by.present? && search_value.present?
        if search_by == '제목'
          where_clause = "travel_posts.title like '%#{search_value}%'"
        elsif search_by == '제목 + 내용'
          where_clause = "travel_posts.title like '%#{search_value}%' or travel_posts.context like '%#{search_value}%'"
        elsif search_by == '작성자'
          where_clause = "users.display_name = '%#{search_value}'%"
        end
      end
      where_clause
    end

    def travel_post_list(page)
      travel_post = self.select('
                travel_posts.id as id,
                travel_posts.title as title,
                travel_posts.context as context,
                travel_posts.user_id as user_id,
                users.display_name as display_name,
                travel_posts.created_at as created_at
                ')
          .joins(:user)
          .left_joins(:travel_comments)
          .group('travel_posts.id')
          .order('travel_posts.id DESC').page(page).per(LIST_PER_PAGE).as_json(include: :travel_post_attachments)

      travel_post.each do |post|
        post['created_at'] = post['created_at'].strftime('%Y-%m-%d %H:%M:%S')
        new_attachments = []
        post['travel_post_attachments'].each do |attachment|
          url = attachment['s3'].url
          new_data = { id: attachment['id'], url: url }
          new_attachments.push(new_data)
        end
        post.except!('travel_post_attachments')
        post['attachments'] = new_attachments

        new_comments = []
        post['travel_posts_comments'].each do |comment|
          display_name = User.find_by_id(comment['user_id']).display_name
          new_data = { id: comment['id'], content: comment['body'], display_name: display_name, created_at: comment['created_at'].strftime('%Y-%m-%d %H:%M:%S') }
          new_comments.push(new_data)
        end
        post.except!('travel_posts_comments')
        post['comments'] = new_comments
      end
    end

    def total_page
      total_page = self.all.count / LIST_PER_PAGE  + 1
      if self.all.count % LIST_PER_PAGE == 0
        total_page = self.all.count / LIST_PER_PAGE
      end
      total_page
    end
  end
end
