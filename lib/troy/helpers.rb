module Troy
  module Helpers
    def h(content)
      CGI.escapeHTML(content)
    end

    def t(*args)
      I18n.t(*args)
    end

    def partial(name, locals = {})
      path = site.root.join("partials/_#{name}.erb")
      EmbeddedRuby.new(path.read, locals.merge(site: site)).render
    rescue Exception, StandardError => error
      raise "Unable to render #{path}; #{error.message}"
    end

    def inline_file(path)
      site.root.join(path).read
    end

    def markdown(text)
      Troy::Markdown.new(text).to_html
    end
  end
end
