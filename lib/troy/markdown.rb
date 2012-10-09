module Troy
  class Markdown
    # Create a new Redcarpet renderer, that prepares the code block
    # to use Prisme.js syntax.
    #
    class Renderer < Redcarpet::Render::HTML
      def block_code(code, language)
        %[<pre class="language-#{language}"><code>#{CGI.escapeHTML(code)}</code></pre>]
      end
    end

    # Set the Markdown markup that must be rendered.
    #
    attr_reader :markup

    def initialize(markup)
      @markup = markup
    end

    def renderer
      @renderer ||= Redcarpet::Markdown.new(Renderer, {
        :autolink => true,
        :space_after_headers => true,
        :fenced_code_blocks => true
      })
    end

    def to_html
      renderer.render(markup)
    end
  end
end
