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
      I18n.load_path += Troy.configuration.i18n.load_path
      I18n.locale = Troy.configuration.i18n.locale
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
      export_pages
      copy_images
    end

    #
    #
    def copy_images
      FileUtils.cp_r(root.join("assets/images"), root.join("public/images"))
    end

    #
    #
    def remove_public_dir
      FileUtils.rm_rf(root.join("public"))
    end

    #
    #
    def export_pages
      pages.each(&:save)
    end

    #
    #
    def copy_assets
      FileUtils.cp_r(root.join("assets"), root.join("public"))
    end

    #
    #
    def export_assets
      sprockets = Sprockets::Environment.new
      sprockets.append_path root.join("assets/javascripts")
      sprockets.append_path root.join("assets/stylesheets")

      Troy.configuration.assets.precompile.each do |asset_name|
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
  end
end
