class RenameTagToSlug < ActiveRecord::Migration[6.0]
  def up
    add_column :blogs, :slug, :string, limit: Blog::MAX_SLUG

    Blog.all.each { |b| b.update_column(:slug, b.tag) }
  end

  def down
    remove_column :blogs, :slug
  end
end
