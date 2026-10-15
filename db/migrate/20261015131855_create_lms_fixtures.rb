class CreateLmsFixtures < ActiveRecord::Migration[8.1]
  def change
    create_table :lms_fixtures do |t|
      t.integer :season_id, null: false
      t.integer :event_id, null: false
      t.string  :event_name, limit: LmsFixture::MAX_EVENT_NAME, null: false
      t.integer :fixture_id, null: false
      t.timestamps
    end
    add_index :lms_fixtures, :fixture_id, unique: true
    add_index :lms_fixtures, [:season_id, :event_id]
  end
end
