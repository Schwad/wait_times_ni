class CreateHourlyStats < ActiveRecord::Migration[7.1]
  def change
    create_table :hourly_stats do |t|
      t.references :hospital, null: false, foreign_key: true
      t.datetime :hour, null: false
      t.integer :min_wait
      t.integer :max_wait
      t.float :avg_wait
      t.integer :sample_count
      t.timestamps
    end

    add_index :hourly_stats, [:hospital_id, :hour], unique: true
    add_index :hourly_stats, :hour
  end
end
