class CreateCashes < ActiveRecord::Migration[5.0]
  def change
    create_table :cashes do |t|
      t.string :date
      t.integer :money
      t.string :description
      t.integer :status
      t.timestamps
    end
  end
end
