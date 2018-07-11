require 'rails_helper'

RSpec.describe "notice_attachments/index", type: :view do
  before(:each) do
    assign(:notice_attachments, [
      NoticeAttachment.create!(
        :notice_id => 2,
        :s3 => "S3"
      ),
      NoticeAttachment.create!(
        :notice_id => 2,
        :s3 => "S3"
      )
    ])
  end

  it "renders a list of notice_attachments" do
    render
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "S3".to_s, :count => 2
  end
end
