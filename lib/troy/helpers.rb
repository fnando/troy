module Troy
  module Helpers
    def h(content)
      CGI.escapeHTML(content)
    end

    def partial(name, locals = {})
      path = site.root.join("partials/_#{name}.erb")
      EmbeddedRuby.new(path.read, locals).render
    end

    def inline_file(path)
      site.root.join(path).read
    end

    def markdown(text)
      Troy::Markdown.new(text).to_html
    end
  end
end
