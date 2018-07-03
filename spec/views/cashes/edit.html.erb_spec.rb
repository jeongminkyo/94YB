require 'rails_helper'

RSpec.describe "cashes/edit", type: :view do
  before(:each) do
    @cash = assign(:cash, Cash.create!(
      :income => 1,
      :expenditure => 1
    ))
  end

  it "renders the edit cash form" do
    render

    assert_select "form[action=?][method=?]", cash_path(@cash), "post" do

      assert_select "input#cash_income[name=?]", "cash[income]"

      assert_select "input#cash_expenditure[name=?]", "cash[expenditure]"
    end
  end
end
