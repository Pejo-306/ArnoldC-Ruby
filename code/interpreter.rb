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
    attr_reader :name, :args, :scope

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
    attr_reader :name, :parameter_values
    attr_writer :return
    attr_accessor :body, :parameters, :closure

    def initialize(name)
        @name = name
        @body = []
        @parameters = []  # set only when the function is declared
        @parameter_values = {}  # altered everytime the function is called
        @closure = {}
        @return = false
        @should_stop = false
    end
    
    def should_return?
        @return
    end

    def return_value
        @return
    end

    def stop_execution
        @should_stop = true
    end

    def execute(*values)
        # @parameter_values is a hash whose keys are parameter names
        # and whose parameter values are the values passed when calling
        # the function
        @parameter_values = @parameters.zip(values).to_h
        @body.each do |expression|
            break if @should_stop
            expression.evaluate
        end
        @parameter_values = {} 
        @should_stop = false
    end
 
    def to_s
        params = ""
        @parameters.each { |name| params.concat(name.to_s + ", ") }
        params.slice!(-2..-1)
        "ArnoldCFunction: #{@name}(#{params})"
    end
end

module ArnoldCPM
    module Interpreter
        @@current_scope = []
        @@buffer = nil  # used for temporary storage of variables

        # Function related expressions

        def its_showtime
            @@current_scope.push ArnoldCFunction.new(:main)
        end

        def you_have_been_terminated
            func = @@current_scope.pop
            func_storage = self.class_variable_get(:@@functions)
            func_storage[func.name] = func
        end

        def listen_to_me_very_carefully(name)
            @@current_scope.push ArnoldCFunction.new(name)
        end

        def i_need_your_clothes_your_boots_and_your_motorcycle(name)
            @@current_scope.last.parameters.push name
        end

        def give_these_people_air
            @@current_scope.last.return = true
        end

        def hasta_la_vista_baby
            func = @@current_scope.pop
            func_storage = self.class_variable_get(:@@functions)
            func_storage[func.name] = func
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

        def ill_be_back(object=nil)
            scope = get_scope_copy
            statement = ArnoldCStatement.new(__method__, scope, object) 
            statement.code do
                func = get_function(statement.scope)
                func.stop_execution
                if func.should_return?
                    func.return = interpret_expression(object, statement.scope)
                end
            end
            @@current_scope.last.body.push statement
        end

        def get_your_ass_to_mars(name)
            scope = get_scope_copy
            statement = ArnoldCStatement.new(__method__, scope, name)
            statement.code do
                variable = ArnoldCVariable.new(statement.args.first)
                @@buffer = variable
            end
            @@current_scope.last.body.push statement 
        end

        def do_it_now(name, *args)
            scope = get_scope_copy
            statement = ArnoldCStatement.new(__method__, scope, name, *args)
            statement.code do
                called_func = self.class_variable_get(:@@functions)[name]

                # store the variable, declared in get_your_ass_to_mars for later
                result_var = @@buffer if called_func.should_return?
                func_returns = if called_func.should_return? then true else false end

                # call the function, identified via name
                values = args.map do |object|
                    interpret_expression(object, statement.scope)
                end
                called_func = self.class_variable_get(:@@functions)[name]
                called_func.execute(*values) 

                # save the result of the function execution to a variable
                # if the function is non-void
                if func_returns
                    result_var.value = called_func.return_value
                    func = get_function(statement.scope)
                    func.closure[result_var.name] = result_var 
                    @@buffer = nil
                end
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
                if func.parameters.include? object
                    # first, check if the variable requested
                    # is in the function's parameters
                    func.parameter_values[object]
                else
                    # otherwise, the requested variable
                    # must be in the function's closure
                    func.closure[object].value    
                end
            else
                object  # object is a literal value
            end
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
    listen_to_me_very_carefully _add
    i_need_your_clothes_your_boots_and_your_motorcycle _x
    i_need_your_clothes_your_boots_and_your_motorcycle _y
    give_these_people_air
        get_to_the_chopper _result
            here_is_my_invitation _x
            get_up _y
        enough_talk
        ill_be_back _result
    hasta_la_vista_baby

    its_showtime
        get_to_the_chopper _x
            here_is_my_invitation 42
        enough_talk
        get_to_the_chopper _y
            here_is_my_invitation 28
        enough_talk

        get_your_ass_to_mars _result
        do_it_now _add, _x, _y
        talk_to_the_hand _result
    you_have_been_terminated
end
