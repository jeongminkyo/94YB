require 'rails_helper'

RSpec.describe "post_attachments/show", type: :view do
  before(:each) do
    @post_attachment = assign(:post_attachment, PostAttachment.create!(
      :post_id => 2,
      :s3 => "S3"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/S3/)
  end
end
