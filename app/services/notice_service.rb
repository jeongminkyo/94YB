class NoticeService < ApplicationService

  class << self
    def notice_list(page)
      notices = Notice.notice_list(page)

      {
          total_page: Notice.total_page,
          notices: notices
      }
    rescue ::YbErrors::Logic => e
      raise e
    rescue => e
      Rails.logger.warn(e, {}, { page: page }, NOTICE_LIST_ERROR)
      nil
    end

    private


  end
end