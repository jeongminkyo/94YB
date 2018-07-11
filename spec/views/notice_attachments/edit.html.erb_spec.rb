require 'rails_helper'

RSpec.describe "notice_attachments/edit", type: :view do
  before(:each) do
    @notice_attachment = assign(:notice_attachment, NoticeAttachment.create!(
      :notice_id => 1,
      :s3 => "MyString"
    ))
  end

  it "renders the edit notice_attachment form" do
    render

    assert_select "form[action=?][method=?]", notice_attachment_path(@notice_attachment), "post" do

      assert_select "input#notice_attachment_notice_id[name=?]", "notice_attachment[notice_id]"

      assert_select "input#notice_attachment_s3[name=?]", "notice_attachment[s3]"
    end
  end
end
