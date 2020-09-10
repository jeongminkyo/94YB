class TravelPostService < ApplicationService

  class << self
    def travel_post_list(page)
      travel_post = TravelPost.travel_post_list(page)

      {
          total_page: TravelPost.total_page,
          travel_posts: travel_post
      }
    rescue ::YbErrors::Logic => e
      raise e
    rescue => e
      Rails.logger.warn(e, {}, { page: page }, TRAVEL_POST_LIST_ERROR)
      nil
    end

    private


  end
end