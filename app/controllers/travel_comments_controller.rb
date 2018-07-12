class TravelCommentsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_travel_post
  before_action :set_travel_comment, only: :destroy

  def create
    params[:travel_comment][:user_id] = current_user.id
    @travel_comment = @travel_post.travel_comments.new(comment_params)
    @travel_comment.save
  end

  def destroy
    authorize_action_for @travel_comment
      @travel_comment.destroy
  end

  private

  def set_travel_post
    @travel_post = TravelPost.find(params[:travel_post_id])
  end

  def set_travel_comment
    @travel_comment = @travel_post.travel_comments.find(params[:id])
  end

  def comment_params
    params.require(:travel_comment).permit(:body, :user_id)
  end
end
