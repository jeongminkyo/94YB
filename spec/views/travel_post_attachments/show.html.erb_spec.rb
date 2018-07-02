require 'rails_helper'

RSpec.describe "travel_post_attachments/show", type: :view do
  before(:each) do
    @travel_post_attachment = assign(:travel_post_attachment, TravelPostAttachment.create!(
      :travel_post_id => 2,
      :s3 => "S3"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/S3/)
  end
end
