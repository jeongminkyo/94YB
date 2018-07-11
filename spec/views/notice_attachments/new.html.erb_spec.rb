require 'rails_helper'

RSpec.describe "notice_attachments/new", type: :view do
  before(:each) do
    assign(:notice_attachment, NoticeAttachment.new(
      :notice_id => 1,
      :s3 => "MyString"
    ))
  end

  it "renders new notice_attachment form" do
    render

    assert_select "form[action=?][method=?]", notice_attachments_path, "post" do

      assert_select "input#notice_attachment_notice_id[name=?]", "notice_attachment[notice_id]"

      assert_select "input#notice_attachment_s3[name=?]", "notice_attachment[s3]"
    end
  end
end
