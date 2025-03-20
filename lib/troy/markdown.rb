# frozen_string_literal: true

module Troy
  class Markdown
    # Match the id portion of a header, as in `# Title {#custom-id}`.
    HEADING_ID = /^(?<text>.*?)(?: {#(?<id>.*?)})?$/

    # Create a new Redcarpet renderer, that prepares the code block
    # to use Prisme.js syntax.
    #
    module PrismJs
      def block_code(code, language)
        code = CGI.escapeHTML(code)
        %[<pre class="language-#{language}"><code>#{code}</code></pre>]
      end
    end

    # Create a new Redcarpet renderer, that prepares the code block
    # to use rouge syntax.
    #
    module Rouge
      include ::Rouge::Plugins::Redcarpet

      # Be more flexible than github and support any arbitrary name.
      ALERT_MARK = /^\[!(?<type>[A-Z]+)\](?<title>.*?)?$/

      # Support alert boxes just like github.
      # https://github.com/orgs/community/discussions/16925
      def block_quote(quote)
        html = Nokogiri::HTML.fragment(quote)
        element = html.children.first
        matches = element.text.to_s.match(ALERT_MARK) if element
        return "<blockquote>#{quote}</blockquote>" unless matches

        element.remove

        type = matches[:type].downcase
        title = matches[:title].to_s.strip
        title = I18n.t(type, scope: :alerts, default: title)

        html = Nokogiri::HTML.fragment <<~HTML
          <div class="alert-message #{type}">
            <p class="alert-message--title"></p>
            #{html}
          </div>
        HTML

        if title.empty?
          html.css(".alert-message--title").first.remove
        else
          html.css(".alert-message--title").first.content = title
        end

        html.to_s
      end

      def header(text, level)
        matches = text.strip.match(HEADING_ID)
        title = matches[:text].strip
        html = Nokogiri::HTML.fragment("<h#{level}>#{title}</h#{level}>")
        heading = html.first_element_child
        title = heading.text

        id = matches[:id]
        id ||= permalink(title)

        heading_counter[id] += 1
        id = "#{id}-#{heading_counter[id]}" if heading_counter[id] > 1

        heading.add_child %[<a class="anchor" href="##{id}" aria-hidden="true" tabindex="-1"></a>] # rubocop:disable Style/LineLength
        heading.set_attribute :tabindex, "-1"
        heading.set_attribute(:id, id)

        heading.to_s
      end

      def permalink(text)
        str = text.dup.unicode_normalize(:nfkd)
        str = str.gsub(/[^\x00-\x7F]/, "").to_s
        str.gsub!(/[^-\w]+/xim, "-")
        str.gsub!(/-+/xm, "-")
        str.gsub!(/^-?(.*?)-?$/, '\1')
        str.downcase!
        str
      end

      def heading_counter
        @heading_counter ||= Hash.new {|h, k| h[k] = 0 }
      end
    end

    class Renderer < Redcarpet::Render::HTML
      include Redcarpet::Render::HTMLAbbreviations
      include Redcarpet::Render::SmartyPants
      include Rouge
    end

    # Set the Markdown markup that must be rendered.
    #
    attr_reader :markup

    def initialize(markup)
      @markup = markup
    end

    def renderer
      @renderer ||= Redcarpet::Markdown.new(Renderer,
                                            autolink: true,
                                            space_after_headers: true,
                                            fenced_code_blocks: true,
                                            footnotes: true,
                                            tables: true,
                                            strikethrough: true,
                                            highlight: true)
    end

    def to_html
      renderer.render(markup)
    end
  end
end
