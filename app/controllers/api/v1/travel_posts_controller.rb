module Api::V1
  class TravelPostsController < ApplicationController

    skip_before_action :verify_authenticity_token
    prepend_before_action only: [:travel_post_list] do
      set_user_by_access_token(request.headers['X-YB-ACCESS-TOKEN'])
    end

    before_action only: [:travel_post_list] do
      check_authenticate_member(@user)
    end

    # GET /api/v1/travel_posts
    def travel_post_list
      log_options = { log_event_code: TRAVEL_POST_LIST_ERROR }
      page = params[:page].blank? ? 1 : params[:page]

      travel_posts = TravelPostService.travel_post_list(page)
      raise InternalServer.new(log_options.merge({ log_message: 'cash list load fail'})) unless travel_posts.present?

      render yb:travel_posts, status: :ok
    end


  end
end

