class CreateUserToken < ActiveRecord::Migration[5.0]
  def change
    create_table :user_tokens do |t|
      t.integer :user_id
      t.text :refresh_token
    end
  end
end
