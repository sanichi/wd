class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.text       :pgn
      t.string     :title, limit: Game::MAX_TITLE
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
