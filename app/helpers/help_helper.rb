module HelpHelper
  SECTIONS = {
    get_login:   "Get a Username and Password",
    create_news: "Create a News Item",
    create_game: "Create a Game",
    house_style: "House Style",
  }

  def help_content(id)
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
