class CreateCalendars < ActiveRecord::Migration[5.0]
  def change
    create_table :calendars do |t|
      t.string :start_date
      t.string :end_date
      t.string :title
      t.integer :user_id

      t.timestamps
    end
  end
end
