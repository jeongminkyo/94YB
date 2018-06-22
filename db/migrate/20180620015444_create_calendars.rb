class CreateCalendars < ActiveRecord::Migration[5.0]
  def change
    create_table :calendars do |t|
      t.datetime :start
      t.datetime :end
      t.string :title
      t.integer :user_id

      t.timestamps
    end
  end
end
