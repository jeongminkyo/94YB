class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :post_attachments
  has_many :post_likes
  accepts_nested_attributes_for :post_attachments
end
