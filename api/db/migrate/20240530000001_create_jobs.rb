class CreateJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :jobs do |t|
      t.text :description
      t.references :company, null: false, foreign_key: true
      t.text :benefits
      t.string :keywords
      t.datetime :start_time
      t.datetime :end_time
      t.integer :interval_time
      t.integer :status, default: 0
      t.text :prompt

      t.timestamps
    end
    
    add_index :jobs, :status
    add_index :jobs, :keywords
  end
end 