class AddCurrentMoneyToCashes < ActiveRecord::Migration[5.0]
  def change
    add_column :cashes, :current_money, :integer
  end
end
