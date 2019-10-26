module Remarkable
  class CustomRenderer < Redcarpet::Render::HTML
    def link(link, title, content)
      link, target = split(link)
      html = %Q(<a href="#{link}")
      html += %Q( title="#{title}") if title.present?
      html += %Q( target="#{target}") if target.present?
      html += %Q(>#{content}</a>)
      html
    end

    def table(header, body)
      <<-EOT
      <table class="table-bordered table-striped" style="margin-left:auto;margin-right:auto">
        #{header}#{body}
      </table>
      EOT
    end

    private

    def split(link)
      if link =~ /\A(.+)\|(\w*)\z/
        [$1, $2.present? ? $2 : "external"]
      else
        [link, nil]
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
