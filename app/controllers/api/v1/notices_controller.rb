module Api::V1
  class NoticesController < ApplicationController

    # GET /api/v1/notices
    def notice_list
      page = params[:page].blank? ? 1 : params[:page]

      @notices = Notice.notice_list(page)

      render json: @notices
    end


  end
end

