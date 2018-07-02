require 'rails_helper'

RSpec.describe "TravelPostAttachments", type: :request do
  describe "GET /travel_post_attachments" do
    it "works! (now write some real specs)" do
      get travel_post_attachments_path
      expect(response).to have_http_status(200)
    end
  end
end
