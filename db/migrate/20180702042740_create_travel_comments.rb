class CreateTravelComments < ActiveRecord::Migration[5.0]
  def change
    create_table :travel_comments do |t|
      t.references :travel_post, foreign_key: true
      t.text :body

      t.timestamps
    end
  end
end
