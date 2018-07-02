require 'rails_helper'

RSpec.describe "travel_posts/new", type: :view do
  before(:each) do
    assign(:travel_post, TravelPost.new(
      :title => "MyString",
      :context => "MyText",
      :user_id => 1
    ))
  end

  it "renders new travel_post form" do
    render

    assert_select "form[action=?][method=?]", travel_posts_path, "post" do

      assert_select "input#travel_post_title[name=?]", "travel_post[title]"

      assert_select "textarea#travel_post_context[name=?]", "travel_post[context]"

      assert_select "input#travel_post_user_id[name=?]", "travel_post[user_id]"
    end
  end
end
