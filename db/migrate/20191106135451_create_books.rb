class CreateBooks < ActiveRecord::Migration[6.0]
  def change
    create_table :books do |t|
      t.string   :author, limit: Book::MAX_AUTHOR
      t.string   :borrowers, limit: Book::MAX_BORROWERS
      t.string   :category, limit: Book::MAX_CATEGORY
      t.integer  :copies, limit: 1, default: 1
      t.string   :medium, limit: Book::MAX_MEDIUM, default: "book"
      t.string   :note, limit: Book::MAX_NOTE
      t.string   :title, limit: Book::MAX_TITLE
      t.integer  :year, limit: 2

      t.timestamps null: false
    end
  end
end
