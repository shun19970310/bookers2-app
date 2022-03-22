class AddIntroductionToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :introducion, :text
  end
end
