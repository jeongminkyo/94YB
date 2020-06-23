module Api::V1
  class TravelPostsController < ApplicationController

    # GET /api/v1/notices
    def travel_post_list
      page = params[:page].blank? ? 1 : params[:page]

      @travel_post = TravelPost.travel_post_list(page)

      render json: @travel_post
    end


  end
end

