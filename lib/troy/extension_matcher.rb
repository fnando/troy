# frozen_string_literal: true

module Troy
  class ExtensionMatcher
    attr_reader :path, :performed, :matchers

    def initialize(path)
      @path = path
      @matchers = {}
    end

    def on(extension, &block)
      matchers[".#{extension}"] = block
      self
    end

    def default(&block)
      matchers["default"] = block
      self
    end

    def match
      matchers.each do |ext, handler|
        return handler.call if File.basename(path).end_with?(ext)
      end

      matchers["default"]&.call
    end
  end
end
