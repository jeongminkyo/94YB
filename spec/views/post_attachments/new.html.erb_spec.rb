require 'rails_helper'

RSpec.describe "post_attachments/new", type: :view do
  before(:each) do
    assign(:post_attachment, PostAttachment.new(
      :post_id => 1,
      :s3 => "MyString"
    ))
  end

  it "renders new post_attachment form" do
    render

    assert_select "form[action=?][method=?]", post_attachments_path, "post" do

      assert_select "input#post_attachment_post_id[name=?]", "post_attachment[post_id]"

      assert_select "input#post_attachment_s3[name=?]", "post_attachment[s3]"
    end
  end
end
