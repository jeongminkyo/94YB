class CreateIncomeHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :income_histories do |t|
      t.integer :cash_id
      t.integer :user_id
      t.integer :month
      t.integer :year

      t.timestamps
    end
  end
end
