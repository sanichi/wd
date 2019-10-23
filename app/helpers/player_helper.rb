module PlayerHelper
  def player_role_menu(selected)
    opts = Player::ROLES.map { |role| [t("player.roles.#{role}"), role] }
    options_for_select(opts, selected)
  end

  def player_title_menu(selected)
    opts = Player::TITLES.map { |title| [title, title] }
    opts.unshift [t("none"), ""]
    options_for_select(opts, selected)
  end

  def player_roles(player)
    player.roles.map { |role| t("player.roles.#{role}") }.join(", ")
  end
end
