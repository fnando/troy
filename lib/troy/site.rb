# frozen_string_literal: true

module Troy
  class Site
    attr_accessor :root, :options

    def initialize(root, options)
      @root = Pathname.new(root).realpath
      @options = options

      load_configuration
      load_extensions
      set_locale
    end

    def load_extensions
      Dir[root.join("config/**/*helpers.rb")].each do |file|
        require file
      end
    end

    def set_locale
      I18n.load_path += config.i18n.load_path
      I18n.default_locale = config.i18n.locale
      I18n.locale = config.i18n.locale
    end

    def load_configuration
      load root.join("config/troy.rb")
    end

    def export
      remove_public_dir
      export_assets
      export_files
      export_pages
    end

    def export_files
      assets = root.join("assets")

      assets.entries.each_slice(options[:concurrency]) do |slice|
        slice.map do |entry|
          Thread.new { export_file(assets, entry) }
        end.each(&:join)
      end
    end

    def export_file(assets, entry)
      basename = entry.to_s
      return if [".", "..", "javascripts", "stylesheets"].include?(basename)

      FileUtils.rm_rf root.join("public/#{basename}")
      FileUtils.cp_r assets.join(entry), root.join("public/#{basename}")
    end

    def remove_public_dir
      FileUtils.rm_rf root.join("public")
    end

    def export_pages(file = nil)
      file = File.expand_path(file) if file

      pages
        .select {|page| file.nil? || page.path == file }
        .each_slice(options[:concurrency]) do |slice|
          threads = slice.map do |page|
            Thread.new do
              page.save
            end
          end

          threads.each(&:join)
        end
    end

    def export_assets
      sprockets = Sprockets::Environment.new
      sprockets.append_path root.join("assets/javascripts")
      sprockets.append_path root.join("assets/stylesheets")

      if config.assets.compress_css
        sprockets.css_compressor = Sprockets::SassCompressor
      end

      if config.assets.compress_js
        sprockets.js_compressor = Uglifier.new(uglifier_options)
      end

      config.assets.precompile.each_slice(options[:concurrency]) do |slice|
        slice.map do |asset_name|
          Thread.new { export_asset(sprockets, asset_name) }
        end.each(&:join)
      end
    end

    def export_asset(sprockets, asset_name)
      asset = sprockets[asset_name]
      output_file = asset.filename.to_s
                         .gsub(root.join("assets").to_s, "")
                         .gsub(%r{^/}, "")
                         .gsub(/\.scss$/, ".css")
                         .gsub(/\.coffee$/, ".js")

      asset.write_to root.join("public/#{output_file}")
    end

    def uglifier_options
      options = Uglifier::DEFAULTS.dup
      options[:output][:comments] = :none
      options
    end

    def source
      Dir[root.join("source/**/*.{html,erb,md,builder,xml,txt}").to_s]
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
