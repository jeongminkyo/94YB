require 'rails_helper'

RSpec.describe "NoticeAttachments", type: :request do
  describe "GET /notice_attachments" do
    it "works! (now write some real specs)" do
      get notice_attachments_path
      expect(response).to have_http_status(200)
    end
  end
end
