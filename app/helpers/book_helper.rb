module BookHelper
  def book_order_menu(selected)
    options_for_select(%w{year title author}.map { |o| ["by " + t("book.#{o}"), o] }, selected)
  end

  def book_category_menu(selected, search: false)
    opts = Book::CATEGORIES.map { |c| [t("book.categories.#{c}"), c] }
    opts.unshift [search ? t("any") : t("select"), ""]
    options_for_select(opts, selected)
  end

  def book_medium_menu(selected, search: false)
    opts = Book::MEDIA.map { |m| [t("book.media.#{m}"), m] }
    opts.unshift [search ? t("any") : t("select"), ""]
    options_for_select(opts, selected)
  end
end
