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


  end
end

