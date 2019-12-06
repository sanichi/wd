class CreateDragons < ActiveRecord::Migration[6.0]
  def change
    create_table :dragons do |t|
      t.string  :first_name, limit: Dragon::MAX_FIRST_NAME
      t.string  :last_name, limit: Dragon::MAX_LAST_NAME
      t.boolean :male, default: true

      t.timestamps null: false
    end
  end
end
