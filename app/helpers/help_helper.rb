module HelpHelper
  SECTIONS = {
    game_controls: "Game Controls",
    book_search:   "Book Search",
    get_login:     "Register as a User",
    otp:           "One Time Passwords",
    create_news:   "Create a News Item",
    add_image:     "Add an Image",
    add_table:     "Add a Tournament Table",
    add_position:  "Add a Position",
    create_game:   "Create a Game",
    house_style:   "House Style",
  }

  def help_link(id)
    _check(id)
    %Q{<a href="##{id}">#{SECTIONS[id]}</a>}.html_safe
  end

  def help_section(id)
    _check(id)
    %Q{<h4 id="#{id}">#{SECTIONS[id]}</h4>}.html_safe
  end

  def _check(id)
    raise "no such section" unless SECTIONS.has_key?(id)
  end
end
