class CreateNotices < ActiveRecord::Migration[5.0]
  def change
    create_table :notices do |t|
      t.string :title
      t.text :context
      t.integer :user_id

      t.timestamps
    end
  end
end
