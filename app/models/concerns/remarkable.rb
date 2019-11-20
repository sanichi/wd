module Remarkable
  class CustomRenderer < Redcarpet::Render::HTML
    def link(link, title, content)
      link.sub!(/\Ahttps?:\/\/(www\.)?wanderingdragonschess.club/, "")
      link = "/" if link.blank?
      html = %Q(<a href="#{link}")
      html += %Q( title="#{title}") if title.present?
      html += %Q( target="external") if link.match?(/\Ahttps?:\/\//)
      html += %Q(>#{content}</a>)
      html
    end

    def image(link, title, alt)
      link.sub!(/\Ahttps?:\/\/(www\.)?wanderingdragonschess.club/, "")
      link = "/img/photos/#{link}" unless link.match?(/\//)
      width = title&.match(/([1-9]\d*(?:px|%)?)/) ? $1 : "200px"
      klass = "rounded "
      if title&.match?(/R/)
        klass += "float-right ml-3"
      elsif title&.match?(/L/)
        klass += " float-left mr-3"
      else
        klass += "mx-auto d-block mt-3 mb-3"
      end
      %Q(<img src="#{link}" alt="#{alt}" class="#{klass}" width="#{width}">)
    end
  end

  def to_html(text, filter_html: true)
    return "" unless text.present?
    renderer = CustomRenderer.new(filter_html: filter_html)
    options =
    {
      autolink: false,
      fenced_code_blocks: true,
      no_intra_emphasis: true,
      strikethrough: true,
      tables: true,
      underline: true,
      space_after_headers: true,
    }
    markdown = Redcarpet::Markdown.new(renderer, options)
    markdown.render(text).html_safe
  end
end
