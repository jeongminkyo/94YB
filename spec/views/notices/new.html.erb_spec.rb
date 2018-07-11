require 'rails_helper'

RSpec.describe "notices/new", type: :view do
  before(:each) do
    assign(:notice, Notice.new(
      :title => "MyString",
      :context => "MyText",
      :user_id => 1
    ))
  end

  it "renders new notice form" do
    render

    assert_select "form[action=?][method=?]", notices_path, "post" do

      assert_select "input#notice_title[name=?]", "notice[title]"

      assert_select "textarea#notice_context[name=?]", "notice[context]"

      assert_select "input#notice_user_id[name=?]", "notice[user_id]"
    end
  end
end
