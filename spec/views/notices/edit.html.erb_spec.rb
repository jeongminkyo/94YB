require 'rails_helper'

RSpec.describe "notices/edit", type: :view do
  before(:each) do
    @notice = assign(:notice, Notice.create!(
      :title => "MyString",
      :context => "MyText",
      :user_id => 1
    ))
  end

  it "renders the edit notice form" do
    render

    assert_select "form[action=?][method=?]", notice_path(@notice), "post" do

      assert_select "input#notice_title[name=?]", "notice[title]"

      assert_select "textarea#notice_context[name=?]", "notice[context]"

      assert_select "input#notice_user_id[name=?]", "notice[user_id]"
    end
  end
end
