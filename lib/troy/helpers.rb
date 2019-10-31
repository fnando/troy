# frozen_string_literal: true

module Troy
  module Helpers
    def h(content)
      CGI.escapeHTML(content)
    end

    def t(*args)
      I18n.t(*args)
    end

    def partial(name, locals = {})
      name = name.to_s
      basename = File.basename(name)
      dirname = File.dirname(name)
      partial = []
      partial << dirname unless dirname.start_with?(".")
      partial << "_#{basename}.erb"
      partial = partial.join("/")

      path = site.root.join("partials/#{partial}")
      locals = locals.merge(site: site, page: page)
      EmbeddedRuby.new(path.read, locals).render
    rescue Exception => error
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
