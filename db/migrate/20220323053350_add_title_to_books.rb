class AddTitleToBooks < ActiveRecord::Migration[6.1]
  def change
    add_column :books, :title, :string
    add_column :books, :body, :text
    add_column :books, :user_id, :integer
  end
end
