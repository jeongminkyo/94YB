require 'rails_helper'

RSpec.describe "travel_posts/show", type: :view do
  before(:each) do
    @travel_post = assign(:travel_post, TravelPost.create!(
      :title => "Title",
      :context => "MyText",
      :user_id => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/2/)
  end
end
