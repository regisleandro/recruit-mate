class AddOpenaiKeyToRecruiters < ActiveRecord::Migration[7.1]
  def change
    add_column :recruiters, :openai_key, :string
  end
end
