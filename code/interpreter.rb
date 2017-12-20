class ArnoldCVariable
    attr_reader :name
    attr_accessor :value

    def initialize(name, value=nil)
        @name = name
        @value = value
    end

    def to_s
        @name
    end
end

class ArnoldCStatement
    attr_reader :name, :scope, :args

    def initialize(name, scope, *args)
        # @name and @args are redundant, however they provide
        # information about the statement to the programmer
        @name = name
        @args = args
        @scope = scope
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
    attr_accessor :body

    def initialize(condition, scope)
        @condition = condition
        @body = []
        @if_body = []
        @else_body = []
        @scope = scope
    end 

    def switch_to_else
        @if_body = @body[0..@body.length-1]
        @body = []
    end 

    def end_if
        if @if_body.empty?  # i.e. an else clause is not present
            @if_body = @body[0..@body.length-1]
        else
            @else_body = @body[0..@body.length-1] 
        end
        @body = []
    end

    def evaluate
        # transform @condition into a ruby bool
        condition = ArnoldCPM.send :interpret_expression, @condition, @scope
        condition = ArnoldCPM.send :from_arnoldc_bool, condition

        # evaluate condition
        if condition 
            @if_body.each do |expression|
                expression.evaluate
            end
        else
            @else_body.each do |expression|
                expression.evaluate
            end
        end
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
        @body.each do |expression|
            expression.evaluate
        end
    end
end

module ArnoldCPM
    module Interpreter
        @@current_scope = []
        @@buffer = nil  # used for temporary storage of variables

        # Function related

        def its_showtime
            main = ArnoldCFunction.new(:main)
            @@current_scope.push main
        end

        def you_have_been_terminated
            define_function @@current_scope.pop
        end

        # Statements

        def talk_to_the_hand(object)
            scope = get_scope_copy
            statement = ArnoldCStatement.new(__method__, scope, object)
            statement.code do
                printer.print interpret_expression(object, statement.scope), "\n"
            end
            @@current_scope.last.body.push statement
        end

        def get_to_the_chopper(name)
            scope = get_scope_copy
            statement = ArnoldCStatement.new(__method__, scope, name)
            statement.code do
                variable = ArnoldCVariable.new(statement.args.first)
                @@buffer = variable
            end
            @@current_scope.last.body.push statement
        end

        def here_is_my_invitation(object)
            scope = get_scope_copy
            statement = ArnoldCStatement.new(__method__, scope, object)
            statement.code do
                @@buffer.value = interpret_expression(object, statement.scope)
            end
            @@current_scope.last.body.push statement
        end

        def enough_talk
            scope = get_scope_copy
            statement = ArnoldCStatement.new(__method__, scope)
            statement.code do
                func = get_function(statement.scope)
                func.closure[@@buffer.name] = @@buffer
                @@buffer = nil
            end
            @@current_scope.last.body.push statement
        end

        # Arithmetics

        def get_up(object)
            scope = get_scope_copy
            statement = ArnoldCStatement.new(__method__, scope, object)
            statement.code do
                @@buffer.value += interpret_expression(object, scope)
            end
            @@current_scope.last.body.push statement
        end

        def get_down(object)
            scope = get_scope_copy
            statement = ArnoldCStatement.new(__method__, scope, object)
            statement.code do
                @@buffer.value -= interpret_expression(object, scope)
            end
            @@current_scope.last.body.push statement
        end

        def youre_fired(object)
            scope = get_scope_copy
            statement = ArnoldCStatement.new(__method__, scope, object)
            statement.code do
                @@buffer.value *= interpret_expression(object, scope)
            end
            @@current_scope.last.body.push statement
        end

        def he_had_to_split(object)
            scope = get_scope_copy
            statement = ArnoldCStatement.new(__method__, scope, object)
            statement.code do
                @@buffer.value /= interpret_expression(object, scope)
            end
            @@current_scope.last.body.push statement
        end

        def i_let_him_go(object)
            scope = get_scope_copy
            statement = ArnoldCStatement.new(__method__, scope, object)
            statement.code do
                @@buffer.value %= interpret_expression(object, scope)
            end
            @@current_scope.last.body.push statement
        end

        # Logical constants

        def no_problemo() 1 end
        def i_lied() 0 end
        
        # Logical operations

        def consider_that_a_divorce(object)
            scope = get_scope_copy
            statement = ArnoldCStatement.new(__method__, scope, object)
            statement.code do
                if from_arnoldc_bool(@@buffer.value) || 
                    from_arnoldc_bool(interpret_expression(object, scope))
                    @@buffer.value = no_problemo
                else
                    @@buffer.value = i_lied
                end
            end
            @@current_scope.last.body.push statement 
        end

        def knock_knock(object)
            scope = get_scope_copy
            statement = ArnoldCStatement.new(__method__, scope, object)
            statement.code do
                if from_arnoldc_bool(@@buffer.value) && 
                    from_arnoldc_bool(interpret_expression(object, scope))
                    @@buffer.value = no_problemo
                else
                    @@buffer.value = i_lied
                end
            end
            @@current_scope.last.body.push statement 
        end

        # Comparisons 

        def let_off_some_steam_bennet(object)
            scope = get_scope_copy
            statement = ArnoldCStatement.new(__method__, scope, object)
            statement.code do
                if @@buffer.value > interpret_expression(object, scope)
                    @@buffer.value = no_problemo
                else
                    @@buffer.value = i_lied
                end
            end
            @@current_scope.last.body.push statement 
        end

        def you_are_not_you_you_are_me(object)
            scope = get_scope_copy
            statement = ArnoldCStatement.new(__method__, scope, object)
            statement.code do
                if @@buffer.value == interpret_expression(object, scope)
                    @@buffer.value = no_problemo
                else
                    @@buffer.value = i_lied
                end
            end
            @@current_scope.last.body.push statement 
        end

        # Conditionals
        def because_im_going_to_say_please(condition)
            conditional = ArnoldCConditional.new(condition, get_scope_copy)
            @@current_scope.push conditional
        end

        def bull_shit
            @@current_scope.last.switch_to_else
        end

        def you_have_no_respect_for_logic
            conditional = @@current_scope.pop
            conditional.end_if
            @@current_scope.last.body.push conditional
        end
 
        private

        def from_arnoldc_bool(arnoldc_bool)
            if arnoldc_bool == 0 then false else true end
        end

        def get_scope_copy
            @@current_scope.map { |expression| expression }
        end

        def interpret_expression(object, scope) 
            if object.is_a? Symbol  # i.e. object is a variable name
                func = get_function(scope)
                func.closure[object].value    
            else
                object  # object is a literal value
            end
        end

        def define_function(func)
            funcs = self.class_variable_get(:@@functions)
            funcs[func.name] = func
        end

        def get_function(scope)
            func_index = scope.reverse.find_index do |expression|
                expression.is_a? ArnoldCFunction
            end
            scope.reverse[func_index]
        end

        def reset_interpreter
            @@current_scope = []
            @@buffer = nil
        end
    end
    
    extend Interpreter
    private_constant :Interpreter

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
        get_to_the_chopper _var
            here_is_my_invitation 42
        enough_talk

        get_to_the_chopper _other
            here_is_my_invitation _var
            knock_knock i_lied
        enough_talk

        because_im_going_to_say_please _other
            because_im_going_to_say_please _var
                talk_to_the_hand 55
            you_have_no_respect_for_logic
        bull_shit
            because_im_going_to_say_please _var
                talk_to_the_hand 90
            bull_shit
                talk_to_the_hand 22
            you_have_no_respect_for_logic
        you_have_no_respect_for_logic
    you_have_been_terminated
end

