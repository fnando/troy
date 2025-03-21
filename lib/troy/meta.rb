# frozen_string_literal: true

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
      @data ||=
        REGEX.match?(raw) ? YAML.unsafe_load(raw[REGEX, 1]) : {}
    end

    def method_missing(name, *_args)
      data[name.to_s]
    end

    def respond_to_missing?(_method, _include_private = false)
      true
    end

    def raw
      @raw ||= File.read(file)
    end
  end
end
