require 'rails_helper'

RSpec.describe "travel_post_attachments/edit", type: :view do
  before(:each) do
    @travel_post_attachment = assign(:travel_post_attachment, TravelPostAttachment.create!(
      :travel_post_id => 1,
      :s3 => "MyString"
    ))
  end

  it "renders the edit travel_post_attachment form" do
    render

    assert_select "form[action=?][method=?]", travel_post_attachment_path(@travel_post_attachment), "post" do

      assert_select "input#travel_post_attachment_travel_post_id[name=?]", "travel_post_attachment[travel_post_id]"

      assert_select "input#travel_post_attachment_s3[name=?]", "travel_post_attachment[s3]"
    end
  end
end
