class Post < ApplicationRecord
  resourcify
  include Authority::Abilities
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :post_attachments
  has_many :post_likes
  accepts_nested_attributes_for :post_attachments

  LIST_PER_PAGE = 20

  class << self

    def find_post_list(page, where_clause)
      Post.select('
          posts.id,
          posts.title,
          posts.context,
          users.display_name,
          posts.created_at
          ')
          .where(where_clause)
          .joins('JOIN users ON users.id = posts.user_id')
          .order('posts.id DESC').page(page).per(LIST_PER_PAGE)
    end

    def make_where_clause(params)
      return '' if params[:search_by].blank? && params[:search_value].blank?

      search_by = params[:search_by].blank? ? nil : params[:search_by]
      search_value = params[:search_value].blank? ? nil : params[:search_value]
      where_clause = ''

      # key, value 기준 검색 where 조건 생성
      if search_by.present? && search_value.present?
        if search_by == '제목'
          where_clause = "posts.title like '%#{search_value}%'"
        elsif search_by == '제목 + 내용'
          where_clause = "posts.title like '%#{search_value}%' or posts.context like '%#{search_value}%'"
        elsif search_by == '작성자'
          where_clause = "users.display_name = '%#{search_value}'%"
        end
      end
      where_clause
    end

  end
end
