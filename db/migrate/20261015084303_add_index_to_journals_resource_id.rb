class AddIndexToJournalsResourceId < ActiveRecord::Migration[8.1]
  def change
    add_index :journals, :resource_id
  end
end
