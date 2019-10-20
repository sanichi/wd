module BlogHelper
  def blog_order_menu(selected)
    opts = %w/created_descending updated_descending created_ascending updated_ascending/.map { |o| [t("blog.order.#{o}"), o] }
    options_for_select(opts, selected)
  end
end
