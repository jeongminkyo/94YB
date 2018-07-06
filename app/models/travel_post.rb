class TravelPost < ApplicationRecord
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
                travel_posts.created_at as created_at,
                travel_post_attachments.s3 as s3
                ')
                .where(where_clause)
                .joins('JOIN users ON users.id = travel_posts.user_id')
                .joins('LEFT JOIN travel_post_attachments ON travel_posts.id = travel_post_attachments.travel_post_id')
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
  end
end
