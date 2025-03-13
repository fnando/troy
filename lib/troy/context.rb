# frozen_string_literal: true

module Troy
  class Context
    def initialize(options = {})
      options.each do |name, value|
        instance_variable_set(:"@#{name}", value)

        instance_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{name}   # def name
            @#{name}    #   @name
          end           # end
        RUBY
      end
    end

    def to_binding
      binding
    end
  end
end
