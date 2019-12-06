module DragonHelper
  def dragon_order_menu(selected)
    opt = %w/last first/.map { |o| ["by " + I18n.t("dragon.#{o}_name"), o] }
    options_for_select(opt, selected)
  end

  def dragon_gender_menu(selected)
    opt = []
    opt.push [t("both"), ""]
    %w/male female/.each { |g| opt.push [t("dragon.#{g}"), g] }
    options_for_select(opt, selected)
  end
end
