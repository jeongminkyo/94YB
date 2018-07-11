require 'rails_helper'

RSpec.describe "notice_attachments/show", type: :view do
  before(:each) do
    @notice_attachment = assign(:notice_attachment, NoticeAttachment.create!(
      :notice_id => 2,
      :s3 => "S3"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/S3/)
  end
end
