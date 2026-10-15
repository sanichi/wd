class AddNotNullToValidatedColumns < ActiveRecord::Migration[8.1]
  def change
    change_column_null :blogs, :title, false
    change_column_null :blogs, :summary, false
    change_column_null :books, :author, false
    change_column_null :books, :title, false
    change_column_null :dragons, :first_name, false
    change_column_null :dragons, :last_name, false
    change_column_null :games, :pgn, false
    change_column_null :games, :title, false
  end
end
