module Troy
  class ExtensionMatcher
    #
    #
    attr_reader :path

    #
    #
    attr_reader :performed

    #
    #
    attr_reader :matchers

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
        return handler.call if File.extname(path) == ext
      end

      matchers["default"].call if matchers["default"]
    end
  end
end
