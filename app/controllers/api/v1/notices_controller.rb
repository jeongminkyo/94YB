module Api::V1
  class NoticesController < ApplicationController

    # GET /api/v1/notices
    def notice_list
      page = params[:page].blank? ? 1 : params[:page]

      @notices = Notice.notice_list(page)

      notice_list = {
          total_page: Notice.total_page,
          notices: @notices
      }
      render json: notice_list
    end

    def create

    end

    def update

    end

    def delete

    end

    def comment_create
      params[:notice_comment][:user_id] = current_user.id
      @notice_comment = @notice.notice_comments.new(notice_comment_params)
      @notice_comment.save
    end

    def comment_destroy
      authorize_action_for @notice_comment
      @notice_comment.destroy
    end

  end
end

