require "rails_helper"

RSpec.describe TravelPostAttachmentsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/travel_post_attachments").to route_to("travel_post_attachments#index")
    end

    it "routes to #new" do
      expect(:get => "/travel_post_attachments/new").to route_to("travel_post_attachments#new")
    end

    it "routes to #show" do
      expect(:get => "/travel_post_attachments/1").to route_to("travel_post_attachments#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/travel_post_attachments/1/edit").to route_to("travel_post_attachments#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/travel_post_attachments").to route_to("travel_post_attachments#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/travel_post_attachments/1").to route_to("travel_post_attachments#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/travel_post_attachments/1").to route_to("travel_post_attachments#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/travel_post_attachments/1").to route_to("travel_post_attachments#destroy", :id => "1")
    end

  end
end
