class AddRolesToUsers < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :roles, :string, array: true, limit: User::MAX_ROLE, default: ["member"]

    User.all.each { |u| u.update_column(:roles, [u.role]) }
  end

  def down
    remove_column :users, :roles, :string
  end
end
