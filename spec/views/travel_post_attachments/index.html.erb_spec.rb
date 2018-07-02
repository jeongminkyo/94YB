require 'rails_helper'

RSpec.describe "travel_post_attachments/index", type: :view do
  before(:each) do
    assign(:travel_post_attachments, [
      TravelPostAttachment.create!(
        :travel_post_id => 2,
        :s3 => "S3"
      ),
      TravelPostAttachment.create!(
        :travel_post_id => 2,
        :s3 => "S3"
      )
    ])
  end

  it "renders a list of travel_post_attachments" do
    render
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "S3".to_s, :count => 2
  end
end
