class CreateCashes < ActiveRecord::Migration[5.0]
  def change
    create_table :cashes do |t|
      t.integer :income
      t.integer :expenditure
      t.string :date
      t.string :description

      t.timestamps
    end
  end
end
