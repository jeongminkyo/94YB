class AddUniqueIndexToUsers < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :display_name, unique: true
  end
end
