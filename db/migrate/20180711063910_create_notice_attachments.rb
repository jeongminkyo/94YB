class CreateNoticeAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :notice_attachments do |t|
      t.integer :notice_id
      t.string :s3

      t.timestamps
    end
  end
end
