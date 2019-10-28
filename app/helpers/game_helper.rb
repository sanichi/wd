module GameHelper
  def game_difficulty_menu(selected, search: false)
    opts = Game::DIFFICULTIES.map { |diff| [t("game.difficulties.#{diff}"), diff] }
    if search
      %w/problems games/.each { |opt| opts.unshift [t("game.difficulties.#{opt}"), opt] }
      opts.unshift [t("any"), ""]
    else
      opts.unshift [t("game.difficulties.choose"), ""]
    end
    options_for_select(opts, selected)
  end

  def title_and_difficulty(game)
    if game.difficulty.present?
      "#{game.title} (#{t("game.difficulties.#{game.difficulty}").downcase})"
    else
      game.title
    end
  end
end
