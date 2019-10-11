class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :first_name, :last_name, limit: User::MAX_NAME
      t.string :handle, limit: User::MAX_HANDLE
      t.string :role, limit: User::MAX_ROLE, default: "member"
      t.string :password_digest

      t.timestamps
    end
  end
end
