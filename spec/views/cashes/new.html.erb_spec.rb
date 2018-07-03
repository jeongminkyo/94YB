require 'rails_helper'

RSpec.describe "cashes/new", type: :view do
  before(:each) do
    assign(:cash, Cash.new(
      :income => 1,
      :expenditure => 1
    ))
  end

  it "renders new cash form" do
    render

    assert_select "form[action=?][method=?]", cashes_path, "post" do

      assert_select "input#cash_income[name=?]", "cash[income]"

      assert_select "input#cash_expenditure[name=?]", "cash[expenditure]"
    end
  end
end
