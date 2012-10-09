module Troy
  class Context
    def initialize(options = {})
      options.each do |name, value|
        instance_variable_set("@#{name}", value)

        instance_eval <<-RUBY
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
