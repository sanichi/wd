class CreateBlogs < ActiveRecord::Migration[6.0]
  def change
    create_table :blogs do |t|
      t.boolean  :draft, default: false
      t.string   :title, limit: Blog::MAX_TITLE
      t.text     :story
      t.text     :summary

      t.timestamps
    end
  end
end
