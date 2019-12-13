class AddSlugToPlayers < ActiveRecord::Migration[6.0]
  def up
    add_column :players, :slug, :string, limit: Player::MAX_SLUG

    Player.all.each { |p| p.update_column(:slug, p.name.parameterize) }
  end

  def down
    remove_column :players, :slug
  end
end
