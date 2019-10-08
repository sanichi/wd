module BlogHelper
  def blog_order_menu(selected)
    opts = %w/created_des updated_des created_asc updated_asc/.map { |o| [t("blog.order.#{o}"), o] }
    options_for_select(opts, selected)
  end

  def blog_title_with_draft(blog)
    blog.draft ? "#{blog.title} (draft)" : blog.title
  end
end
