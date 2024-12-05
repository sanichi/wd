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
      klass = get_klass(title)
      %Q(<img src="#{link}" alt="#{alt}" class="styled #{klass}" width="#{width}">)
    end

    private

    def get_width(inst)
      if inst&.match(/([1-9]\d*)%/) && $1.to_i <= 100 && $1.to_i >= 10
        "#{$1}%"
      elsif inst&.match(/([1-9]\d*)/) && $1.to_i <= 300 && $1.to_i >= 100
        "#{$1}px"
      else
        "300px"
      end
    end

    def get_klass(inst)
      if inst&.match?(/R/i)
        "float-end ms-3 mt-1 mb-1"
      elsif inst&.match?(/L/i)
        "float-start me-3 mt-1 mb-1"
      else
        "mx-auto d-block mt-3 mb-3"
      end
    end
  end

  def to_html(text, filter_html: true, with_toc_data: true)
    return "" unless text.present?
    renderer = CustomRenderer.new(filter_html: filter_html, with_toc_data: with_toc_data)
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
    # prevent tables squashed by small screens from line-breaking within scores
    text.gsub!(/(\|\s*[\d½]+)-([\d½]+\s*\|)/, '\1&#8209;\2')
    markdown.render(text).html_safe
  end
end
