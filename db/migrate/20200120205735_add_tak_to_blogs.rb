class AddTakToBlogs < ActiveRecord::Migration[6.0]
  def change
    add_column :blogs, :tag, :string, limit: Blog::MAX_TAG
  end
end
