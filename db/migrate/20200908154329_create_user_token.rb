class CreateUserToken < ActiveRecord::Migration[5.0]
  def change
    create_table :user_tokens do |t|
      t.integer :user_id
      t.string :refresh_token
      t.string :push_token

      t.timestamps
    end

    add_index :user_tokens, :refresh_token
    add_index :user_tokens, :push_token
  end
end

