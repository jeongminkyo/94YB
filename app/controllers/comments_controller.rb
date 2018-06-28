class CommentsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_post
  before_action :set_comment, only: :destroy

  def create
    params[:comment][:user_id] = current_user.id
    @comment = @post.comments.new(comment_params)
    @comment.save
  end

  def destroy
    @comment.destroy
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body, :user_id)
  end
end
