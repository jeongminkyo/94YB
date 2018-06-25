require 'rails_helper'

RSpec.describe "posts/new", type: :view do
  before(:each) do
    assign(:post, Post.new(
      :title => "MyString",
      :context => "MyText",
      :user_id => 1
    ))
  end

  it "renders new post form" do
    render

    assert_select "form[action=?][method=?]", posts_path, "post" do

      assert_select "input#post_title[name=?]", "post[title]"

      assert_select "textarea#post_context[name=?]", "post[context]"

      assert_select "input#post_user_id[name=?]", "post[user_id]"
    end
  end
end
