class CreateTravelPostLikes < ActiveRecord::Migration[5.0]
  def change
    create_table :travel_post_likes do |t|
      t.boolean :like
      t.integer :travel_post_id
      t.integer :user_id
      t.timestamps
    end
  end
end