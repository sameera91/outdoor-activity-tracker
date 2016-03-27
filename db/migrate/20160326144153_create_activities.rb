class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :name
      t.datetime :date
      t.string :time
      t.string :distance
      t.string :notes
      t.integer :user_id
      t.integer :location_id
    end
  end
end
