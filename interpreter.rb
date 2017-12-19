class ArnoldCVariable
    def initialize(name, value=nil)
        @name = name
        @value = value
    end

    def to_s
        @name
    end
end

class ArnoldCStatement
    def initialize(name, *args)
        @name = name
        @args = args
        @scope = nil
    end

    def code(&block)

    end
end

class ArnoldCConditional
    def initialize

    end
end

class ArnoldCFunction
    attr_accessor :parameters, :closure, :return

    def initialize(name, scope, body)
        @name = name
        @scope = scope
        @body = body
        @parameters = []
        @closure = {}
        @return = false
    end
    
    def should_return?
        @return
    end

    def execute(*values)
        
    end
end

module ArnoldCPM
    module Interpreter
        def its_showtime

        end

        def you_have_been_terminated

        end

        private
        
        def no_problemo() 1 end
        def i_lied() 0 end
    end

    private_constant :Interpreter

    class << self
        @@current_scope = ''

        def method_missing(name, *args, &block)
            # return name if this is an ArnoldC variable or function name
            return name if args.empty? && !block_given?
            super(name, *args, &block)
        end

        def printer
            @@printer
        end

        def printer=(cls)
            @@printer = cls
        end

        def totally_recall(&code)
            instance_eval &code
        end

        private def reset
            @@current_scope = ''
        end
    end
end

