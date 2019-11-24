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
      link&.sub!(/\Ahttps?:\/\/(www\.)?wanderingdragonschess.club/, "")
      link = "/img/photos/#{link}" unless link&.match?(/\//)
      width = get_width(title)
      klass = get_placement(title)
      %Q(<img src="#{link}" alt="#{alt}" class="styled #{klass}" width="#{width}">)
    end

    private

    def get_width(inst)
      if inst&.match(/([1-9]\d*)%/) && $1.to_i <= 100 && $1.to_i >= 10
        "#{$1}%"
      elsif inst&.match(/([1-9]\d*)/) && $1.to_i <= 300 && $1.to_i >= 100
        "#{$1}px"
      else
        "200px"
      end
    end

    def get_placement(inst)
      if inst&.match?(/R/i)
        "float-right ml-3"
      elsif inst&.match?(/L/i)
        "float-left mr-3"
      else
        "mx-auto d-block mt-3 mb-3"
      end
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
