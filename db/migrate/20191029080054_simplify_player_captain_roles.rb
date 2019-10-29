class SimplifyPlayerCaptainRoles < ActiveRecord::Migration[6.0]
  def up
    Player.all.each do |player|
      redundant = []
      player.roles.each do |r|
        redundant.push "player_#{$1}" if r.match(/\Acaptain_(\w+)\z/)
      end
      unless redundant.empty?
        redundant.each { |role| player.roles.delete(role) }
        player.save
      end
    end
  end

  def down
    Player.all.each do |player|
      essential = []
      player.roles.each do |r|
        essential.push "player_#{$1}" if r.match(/\Acaptain_(\w+)\z/)
      end
      unless essential.empty?
        player.roles += essential
        player.roles.sort_by! { |role| Player::RANK[role] }
        player.save
      end
    end
  end
end
