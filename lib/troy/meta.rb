module Troy
  class Meta
    extend Forwardable
    def_delegators :data, :[], :fetch, :key?

    REGEX = /^---\n(.*?)\n---\n+/m

    attr_reader :file

    def initialize(file)
      @file = file
    end

    def content
      @content ||= raw.gsub(REGEX, "")
    end

    def data
      @data ||= (raw =~ REGEX ? YAML.load(raw[REGEX, 1]) : {})
    end

    def method_missing(name, *args, &block)
      data[name.to_s]
    end

    def respond_to_missing?(method, include_private = false)
      true
    end

    def raw
      @raw ||= File.read(file)
    end
  end
end
