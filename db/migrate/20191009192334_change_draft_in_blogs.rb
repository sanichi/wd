class ChangeDraftInBlogs < ActiveRecord::Migration[6.0]
  def up
    change_column :blogs, :draft, :boolean, default: true
  end

  def down
    change_column :blogs, :draft, :boolean, default: false
  end
end
