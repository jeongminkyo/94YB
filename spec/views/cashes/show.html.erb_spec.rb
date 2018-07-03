require 'rails_helper'

RSpec.describe "cashes/show", type: :view do
  before(:each) do
    @cash = assign(:cash, Cash.create!(
      :income => 2,
      :expenditure => 3
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
  end
end
