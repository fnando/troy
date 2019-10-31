# frozen_string_literal: true

module Troy
  class XML
    # The XML content.
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
      @context ||= Context.new(data.merge(xml: xml)).extend(Helpers)
    end

    def xml
      @xml ||= Builder::XmlMarkup.new(indent: 2)
    end

    def to_xml
      @to_xml ||= begin
        xml.instruct!
        context.instance_eval(content)
        xml.target!
      end
    end
  end
end
