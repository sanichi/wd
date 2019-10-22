class DropRoleFromUsers < ActiveRecord::Migration[6.0]
  def up
    remove_column :users, :role, :string
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
