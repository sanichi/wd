module BlogHelper
  def blog_order_menu(selected)
    opts = %w/created_des updated_des created_asc updated_asc/.map { |o| [t("blog.order.#{o}"), o] }
    options_for_select(opts, selected)
  end

  def blog_user_menu(selected)
    opts = User.pluck(:handle, :id)
    opts.unshift [t("any"), ""]
    options_for_select(opts, selected)
  end
end
