module Troy
  class Site
    attr_accessor :root

    def initialize(root)
      @root = Pathname.new(root).realpath

      load_configuration
      load_extensions
      set_locale
    end

    #
    #
    def load_extensions
      Dir[root.join("config/**/*helpers.rb")].each do |file|
        require file
      end
    end

    #
    #
    def set_locale
      I18n.load_path += config.i18n.load_path
      I18n.default_locale = config.i18n.locale
      I18n.locale = config.i18n.locale
    end

    #
    #
    def load_configuration
      load root.join("config/troy.rb")
    end

    #
    #
    def export
      remove_public_dir
      export_assets
      export_files
      export_pages
    end

    #
    #
    def export_files
      assets = root.join("assets")

      assets.entries.each do |entry|
        basename = entry.to_s
        next if [".", "..", "javascripts", "stylesheets"].include?(basename)
        FileUtils.rm_rf root.join("public/#{basename}")
        FileUtils.cp_r assets.join(entry), root.join("public/#{basename}")
      end
    end

    #
    #
    def remove_public_dir
      FileUtils.rm_rf root.join("public")
    end

    #
    #
    def export_pages(file = nil)
      file = File.expand_path(file) if file

      pages
        .select {|page| file.nil? || page.path == file }
        .each(&:save)
    end

    #
    #
    def export_assets
      sprockets = Sprockets::Environment.new
      sprockets.append_path root.join("assets/javascripts")
      sprockets.append_path root.join("assets/stylesheets")
      sprockets.css_compressor = Sprockets::SassCompressor if config.assets.compress_css
      sprockets.js_compressor = Uglifier.new(copyright: false) if config.assets.compress_js
      sprockets.default_external_encoding = Encoding::UTF_8

      config.assets.precompile.each do |asset_name|
        asset = sprockets[asset_name]
        output_file = asset.pathname.to_s
          .gsub(root.join("assets").to_s, "")
          .gsub(%r[^/], "")
          .gsub(/\.scss$/, ".css")
          .gsub(/\.coffee$/, ".js")

        asset.write_to root.join("public/#{output_file}")
      end
    end

    #
    #
    def source
      Dir[root.join("source/**/*.{html,erb,md,builder,xml}").to_s]
    end

    # Return all pages wrapped in Troy::Page class.
    #
    def pages
      @pages ||= source.map {|path| Page.new(self, path) }
    end

    # A shortcut to the configuration.
    def config
      Troy.configuration
    end
  end
end
