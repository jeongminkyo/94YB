class CreateNoticeComments < ActiveRecord::Migration[5.0]
  def change
    create_table :notice_comments do |t|
      t.references :notice, foreign_key: true
      t.text :body
      t.integer :user_id

      t.timestamps
    end
  end
end
