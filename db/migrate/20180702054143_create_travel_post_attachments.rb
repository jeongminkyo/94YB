class CreateTravelPostAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :travel_post_attachments do |t|
      t.integer :travel_post_id
      t.string :s3

      t.timestamps
    end
  end
end
