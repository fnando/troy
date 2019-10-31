# frozen_string_literal: true

module Troy
  ::I18n.enforce_available_locales = false

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end

  class Configuration < OpenStruct
    def assets
      @assets ||= Configuration.new(
        compress_html: true,
        compress_css: true,
        compress_js: true,
        precompile: []
      )
    end

    def i18n
      @i18n ||= Configuration.new.tap do |config|
        config.load_path = ["config/locales/*.yml"]
      end
    end
  end
end
