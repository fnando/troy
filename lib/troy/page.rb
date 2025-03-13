# frozen_string_literal: true

module Troy
  class Page
    extend Forwardable

    def_delegators :meta, :template

    # Set the page path, which must contain a valid
    # meta section and page content.
    #
    attr_reader :path

    # Set the meta data for this particular page.
    #
    attr_reader :meta

    # Set the current site object, which contains reference to
    # all existing pages.
    #
    attr_reader :site

    # Initialize a new page, which can be simply rendered or
    # persisted to the filesystem.
    #
    def initialize(site, path, meta = nil)
      @site = site
      @path = path
      @meta = meta || Meta.new(path)
    end

    def method_missing(name, *args, &block)
      return meta[name.to_s] if meta.key?(name.to_s)

      super
    end

    def respond_to_missing?(name, _include_private = false)
      meta.key?(name.to_s)
    end

    def content
      ExtensionMatcher
        .new(path)
        .default { meta.content }
        .on("builder") { XML.new(meta.content, to_context).to_xml }
        .on("erb") { EmbeddedRuby.new(meta.content, to_context).render }
        .on("md") { Markdown.new(meta.content).to_html }
        .on("txt") { EmbeddedRuby.new(meta.content, to_context).render }
        .match
    end

    def to_context
      {
        page: self,
        site: site
      }
    end

    def compress(content)
      content = HtmlPress.press(content) if config.assets.compress_html
      content
    end

    # Render the current page.
    #
    def render
      ExtensionMatcher.new(path)
                                  .default { content }
                                  .on("html") { compress render_erb }
                                  .on("md") { compress render_erb }
                                  .on("erb") { compress render_erb }
                                  .match
    end

    def permalink
      meta.fetch("permalink", File.basename(path).gsub(/\..*?$/, ""))
    end

    def filename
      ExtensionMatcher.new(path)
                      .default { "#{permalink}.html" }
                      .on("builder") { "#{permalink}.xml" }
                      .on("xml") { "#{permalink}.xml" }
                      .on("txt") { "#{permalink}.txt" }
                      .match
    end

    def layout
      site.root.join("layouts/#{meta.fetch('layout', 'default')}.erb")
    end

    def render_erb
      if layout.exist?
        EmbeddedRuby.new(
          layout.read,
          to_context.merge(content: content)
        ).render
      else
        content
      end
    end

    # Save current page to the specified path.
    #
    def save_to(path)
      File.open(path, "w") do |file|
        I18n.with_locale(meta.locale) do
          file << render
        end
      end
    end

    def output_file
      base = File.dirname(path)
                 .gsub(site.root.join("source").to_s, "")
                 .gsub(%r{^/}, "")

      site.root.join("public", base, filename)
    end

    def save
      FileUtils.mkdir_p(File.dirname(output_file))
      save_to(output_file)
    end

    def config
      Troy.configuration
    end
  end
end
