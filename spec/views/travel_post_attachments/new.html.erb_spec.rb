require 'rails_helper'

RSpec.describe "travel_post_attachments/new", type: :view do
  before(:each) do
    assign(:travel_post_attachment, TravelPostAttachment.new(
      :travel_post_id => 1,
      :s3 => "MyString"
    ))
  end

  it "renders new travel_post_attachment form" do
    render

    assert_select "form[action=?][method=?]", travel_post_attachments_path, "post" do

      assert_select "input#travel_post_attachment_travel_post_id[name=?]", "travel_post_attachment[travel_post_id]"

      assert_select "input#travel_post_attachment_s3[name=?]", "travel_post_attachment[s3]"
    end
  end
end
