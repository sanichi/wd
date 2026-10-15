class ChangeJournalsCreatedAtNotNull < ActiveRecord::Migration[8.1]
  def change
    change_column_null :journals, :created_at, false
  end
end
