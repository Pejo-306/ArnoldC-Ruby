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
        @code = nil
    end

    def code(&block)
        @code = block
    end

    def evaluate
        @code.call()
    end
end

class ArnoldCConditional
    def initialize

    end
end

class ArnoldCFunction
    attr_reader :name
    attr_accessor :body, :parameters, :closure, :return

    def initialize(name)
        @name = name
        @body = []
        @parameters = []
        @closure = {}
        @return = false
    end
    
    def should_return?
        @return
    end

    def execute(*values)
        @body.each do |statement|
            statement.evaluate
        end
    end
end

module ArnoldCPM
    module Interpreter
        @@current_scope = []

        # Function related
        def its_showtime
            main = ArnoldCFunction.new(:main)
            @@current_scope.push main
        end

        def you_have_been_terminated
            define_function(@@current_scope.pop)
        end

        # Statements
        def talk_to_the_hand(object)
            statement = ArnoldCStatement.new(__method__, object)
            statement.code do
                printer.print object, "\n"
            end
            @@current_scope.last.body.push statement
        end

        # Conditionals

        private
        
        def no_problemo() 1 end
        def i_lied() 0 end

        def define_function(func)
            funcs = self.class_variable_get(:@@functions)
            funcs[func.name] = func
        end

        def reset_interpreter
            @@current_scope = ''
        end
    end

    private_constant :Interpreter

    extend Interpreter

    class << self
        @@functions = {}

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
            @@functions[:main].execute
        end

        private def reset
            @@functions = {}
            reset_interpreter
        end
    end
end

ArnoldCPM.printer = Kernel
ArnoldCPM.totally_recall do
    its_showtime
        talk_to_the_hand 44
    you_have_been_terminated
end

