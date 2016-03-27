class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :name
      t.string :time
      t.string :distance
      t.string :notes
      t.string :user_id
    end
  end
end
