class CreateCandidates < ActiveRecord::Migration[7.1]
  def change
    create_table :candidates do |t|
      t.string :name, null: false
      t.string :curriculum
      t.text :curriculum_summary
      t.string :cellphone_number
      t.string :cpf
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :candidates, :cpf, unique: true
    add_index :candidates, :name
  end
end
