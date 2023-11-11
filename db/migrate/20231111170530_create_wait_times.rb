class CreateWaitTimes < ActiveRecord::Migration[7.1]
  def change
    create_table :wait_times do |t|
      t.integer :value
      t.references :hospital, null: false, foreign_key: true

      t.timestamps
    end
  end
end
