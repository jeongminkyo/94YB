require 'rails_helper'

RSpec.describe "cashes/index", type: :view do
  before(:each) do
    assign(:cashes, [
      Cash.create!(
        :income => 2,
        :expenditure => 3
      ),
      Cash.create!(
        :income => 2,
        :expenditure => 3
      )
    ])
  end

  it "renders a list of cashes" do
    render
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
