module Troy
  class EmbeddedRuby
    # The template content.
    #
    attr_reader :content

    # The data that must be rendered within
    # the Troy::Context object.
    #
    attr_reader :data

    def initialize(content, data)
      @content = content
      @data = data
    end

    def context
      @context ||= Context.new(data).extend(Helpers)
    end

    def render
      ERB.new(content).result context.to_binding
    end
  end
end
