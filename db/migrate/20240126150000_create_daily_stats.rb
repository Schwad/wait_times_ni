class CreateDailyStats < ActiveRecord::Migration[7.1]
  def change
    create_table :daily_stats do |t|
      t.references :hospital, null: false, foreign_key: true
      t.date :date, null: false
      t.integer :min_wait
      t.integer :max_wait
      t.float :avg_wait
      t.integer :sample_count
      t.timestamps
    end

    add_index :daily_stats, [:hospital_id, :date], unique: true
    add_index :daily_stats, :date
  end
end
