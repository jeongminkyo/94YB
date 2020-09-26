module Api::V1
  class NoticesController < ApplicationController

    skip_before_action :verify_authenticity_token
    prepend_before_action only: [:notice_list] do
      set_user_by_access_token(request.headers['X-YB-ACCESS-TOKEN'])
    end

    before_action only: [:notice_list] do
      check_authenticate_member(@user)
    end

    # GET /api/v1/notices
    def notice_list
      log_options = { log_event_code: NOTICE_LIST_ERROR }
      page = params[:page].blank? ? 1 : params[:page]

      notice_list = NoticeService.notice_list(page)

      raise InternalServer.new(log_options.merge({ log_message: 'notice list load fail'})) if notice_list.nil?

      render yb:notice_list, status: :ok
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

