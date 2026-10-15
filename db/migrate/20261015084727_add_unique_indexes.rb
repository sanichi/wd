class AddUniqueIndexes < ActiveRecord::Migration[8.1]
  def change
    add_index :blogs, :slug, unique: true
    add_index :books, [:author, :title], unique: true
    add_index :dragons, [:last_name, :first_name], unique: true
    add_index :players, :email, unique: true
    add_index :players, :fide_id, unique: true
    add_index :players, :sca_id, unique: true
    add_index :players, [:last_name, :first_name], unique: true
    add_index :users, :handle, unique: true
  end
end
