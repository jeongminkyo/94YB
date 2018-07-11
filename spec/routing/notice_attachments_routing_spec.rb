require "rails_helper"

RSpec.describe NoticeAttachmentsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/notice_attachments").to route_to("notice_attachments#index")
    end

    it "routes to #new" do
      expect(:get => "/notice_attachments/new").to route_to("notice_attachments#new")
    end

    it "routes to #show" do
      expect(:get => "/notice_attachments/1").to route_to("notice_attachments#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/notice_attachments/1/edit").to route_to("notice_attachments#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/notice_attachments").to route_to("notice_attachments#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/notice_attachments/1").to route_to("notice_attachments#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/notice_attachments/1").to route_to("notice_attachments#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/notice_attachments/1").to route_to("notice_attachments#destroy", :id => "1")
    end

  end
end
