require "rails_helper"

RSpec.describe TravelPostsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/travel_posts").to route_to("travel_posts#index")
    end

    it "routes to #new" do
      expect(:get => "/travel_posts/new").to route_to("travel_posts#new")
    end

    it "routes to #show" do
      expect(:get => "/travel_posts/1").to route_to("travel_posts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/travel_posts/1/edit").to route_to("travel_posts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/travel_posts").to route_to("travel_posts#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/travel_posts/1").to route_to("travel_posts#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/travel_posts/1").to route_to("travel_posts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/travel_posts/1").to route_to("travel_posts#destroy", :id => "1")
    end

  end
end
