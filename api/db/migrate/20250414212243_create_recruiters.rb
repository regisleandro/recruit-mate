class CreateRecruiters < ActiveRecord::Migration[7.1]
  def change
    create_table :recruiters do |t|
      t.string :name
      t.text :prompt
      t.string :telegram_token

      t.timestamps
    end
  end
end
