class CreateJournals < ActiveRecord::Migration[6.0]
  def change
    create_table :journals do |t|
      t.string   :action, limit: Journal::MAX_ACTION
      t.datetime :created_at
      t.string   :handle, limit: Journal::MAX_HANDLE
      t.integer  :resource_id
      t.string   :remote_ip, limit: Journal::MAX_REMOTE_IP
      t.string   :resource, limit: Journal::MAX_RESOURCE
    end
  end
end
