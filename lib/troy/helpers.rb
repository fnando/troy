module Troy
  module Helpers
    def h(content)
      CGI.escapeHTML(content)
    end

    def partial(name, locals = {})
      path = site.root.join("partials/_#{name}.erb")
      EmbeddedRuby.new(path.read, locals).render
    end
  end
end
