module PlayerHelper
  def player_role_menu(selected, search: false)
    opts = Player::ROLES.map { |role| [t("player.roles.#{role}"), role] }
    opts.unshift [t("any"), ""] if search
    options_for_select(opts, selected)
  end

  def player_title_menu(selected)
    opts = Player::TITLES.map { |title| [title, title] }
    opts.unshift [t("none"), ""]
    options_for_select(opts, selected)
  end

  def player_roles(roles)
    roles.map { |role| t("player.roles.#{role}") }.join(", ")
  end
end
