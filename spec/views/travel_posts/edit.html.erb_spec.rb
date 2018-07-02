require 'rails_helper'

RSpec.describe "travel_posts/edit", type: :view do
  before(:each) do
    @travel_post = assign(:travel_post, TravelPost.create!(
      :title => "MyString",
      :context => "MyText",
      :user_id => 1
    ))
  end

  it "renders the edit travel_post form" do
    render

    assert_select "form[action=?][method=?]", travel_post_path(@travel_post), "post" do

      assert_select "input#travel_post_title[name=?]", "travel_post[title]"

      assert_select "textarea#travel_post_context[name=?]", "travel_post[context]"

      assert_select "input#travel_post_user_id[name=?]", "travel_post[user_id]"
    end
  end
end
