class AddDifficultyToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :difficulty, :string, limit: Game::MAX_DIFFICULTY
  end
end
