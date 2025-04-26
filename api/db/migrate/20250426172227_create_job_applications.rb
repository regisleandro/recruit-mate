class CreateJobApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :job_applications do |t|
      t.references :candidate, null: false, foreign_key: true
      t.references :job, null: false, foreign_key: true
      t.integer :status, default: 0
      t.text :notes

      t.timestamps
    end
    
    add_index :job_applications, :status
    add_index :job_applications, [:candidate_id, :job_id], unique: true
  end
end
