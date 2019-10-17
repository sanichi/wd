class AddPinToBlogs < ActiveRecord::Migration[6.0]
  def change
    add_column :blogs, :pin, :boolean, default: false
  end
end
