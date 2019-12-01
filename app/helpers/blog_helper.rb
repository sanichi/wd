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

  def link_slug(slug)
    blog = Blog.find_by(slug: slug, draft: false)
    return nil unless blog
    link_to blog.title, blog_path(slug)
  end

  def title_icons(blog)
    return nil if current_user.guest?
    icons = []
    icons.push t("blog.icon.draft") if blog.draft?
    icons.push t("blog.icon.pin") if blog.pin?
    return nil if icons.empty?
    icons.join(" ")
  end
end
