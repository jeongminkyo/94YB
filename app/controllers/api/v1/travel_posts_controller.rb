module Api::V1
  class TravelPostsController < ApplicationController

    # GET /api/v1/notices
    def travel_post_list
      page = params[:page].blank? ? 1 : params[:page]

      @travel_post = TravelPost.travel_post_list(page)

      travel_post_list = {
          total_page: TravelPost.total_page,
          travel_posts: @travel_post
      }
      render json: travel_post_list
    end


  end
end

