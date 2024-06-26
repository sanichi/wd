module PlayerHelper
  def player_role_menu(selected, search: false)
    opts = Player::ROLES.map { |role| [t("player.roles.#{role}"), role] }
    if search
      i = opts.index { |opt| opt[1] == "captain_el1" } || 0
      opts.insert(i, [t("player.roles.captain"), "captain"])
      opts.unshift [t("any"), ""]
    end
    options_for_select(opts, selected)
  end

  def player_title_menu(selected)
    opts = Player::TITLES.map { |title| [title, title] }
    opts.unshift [t("none"), ""]
    options_for_select(opts, selected)
  end

  def player_order_menu(selected)
    opts = ["sca", "fide", "name"].map { |order| [t("player.order.#{order}"), order] }
    options_for_select(opts, selected)
  end

  def player_roles(roles)
    roles.map { |role| t("player.roles.#{role}") }.join(", ")
  end

  def player_fide_profile(id)
    link_to id, "https://ratings.fide.com/profile/#{id}", target: "external" if id
  end

  def player_sca_profile(id)
    link_to id, "https://www.chessscotland.com/players/#{id}/", target: "external" if id
  end
end
