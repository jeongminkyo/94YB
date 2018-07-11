class CreateNoticeLikes < ActiveRecord::Migration[5.0]
  def change
    create_table :notice_likes do |t|
      t.boolean :like
      t.integer :notice_id
      t.integer :user_id

      t.timestamps
    end
  end
end
