module Troy
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure(&block)
    yield configuration
  end

  class Configuration < OpenStruct
    def assets
      @assets ||= Configuration.new({
        compress_html: true,
        compress_css: true,
        compress_js: true,
        precompile: []
      })
    end

    def i18n
      @i18n ||= Configuration.new.tap do |config|
        config.load_path = ["config/locales/*.yml"]
      end
    end
  end
end
