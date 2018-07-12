class NoticeCommentsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_notice_post
  before_action :set_notice_comment, only: :destroy

  def create
    params[:notice_comment][:user_id] = current_user.id
    @notice_comment = @notice.notice_comments.new(notice_comment_params)
    @notice_comment.save
  end

  def destroy
    authorize_action_for @notice_comment
      @notice_comment.destroy
  end

  private

  def set_notice_post
    @notice = Notice.find(params[:notice_id])
  end

  def set_notice_comment
    @notice_comment = @notice.notice_comments.find(params[:id])
  end

  def notice_comment_params
    params.require(:notice_comment).permit(:body, :user_id)
  end
end
