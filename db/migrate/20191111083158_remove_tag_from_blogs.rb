class RemoveTagFromBlogs < ActiveRecord::Migration[6.0]
  def up
    remove_column :blogs, :tag
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
