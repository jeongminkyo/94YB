class CreateWallets < ActiveRecord::Migration[5.0]
  def change
    create_table :wallets do |t|
      t.integer :current_money
      t.integer :whole_money

      t.timestamps
    end
  end
end
