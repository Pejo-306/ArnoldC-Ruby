require_relative '../constructs'
require_relative '../errors'

module ArnoldCPM
  module Interpreter
    @@statements = []
    @@current_scope = []
    @@function_stack = ArnoldCFunctionStack.new 
    @@buffer = nil # Used for temporary storage of variables

    def self.extended(base)
      super(base)

      interpreter = self
      @@statements.each do |method_name|
        # Define a singleton method bound to ArnoldCPM for every
        # Method marked as a statement in ArnoldC
        base.define_singleton_method method_name do |*args|
          # Create a new ArnoldC statement 
          statement = ArnoldCStatement.new(
            method_name,
            get_template(@@current_scope),
            *args
          )
          # Set the newly created statement's body to the Ruby code defined in
          # the corresponding module ArnoldCPM::Interpreter's instance method 
          statement.code do
            bound_method = interpreter.instance_method(method_name).bind(self)
            bound_method.call(*args, statement: statement)
            bound_method.unbind
          end
          # Append the new statement to the innermost function template's body
          raise OutOfBoundsError if @@current_scope.last.equal? program
          @@current_scope.last.body.push(statement)
        end
      end
    end

    def its_showtime
      # Initialize a statement which defines the main function via a template
      statement = ArnoldCStatement.new(__method__, program)
      statement.code do
        template = program.templates[:__main__] 
        @@function_stack.push(ArnoldCFunction.new(template)) 
      end
      @@current_scope.last.body.push(statement)
      
      # Create the main function's template
      @@current_scope.push(ArnoldCFunctionTemplate.new(:__main__, program))
    end

    def you_have_been_terminated
      template = @@current_scope.pop # Main function template
      # @@current_scope.last here refers to the function __program__
      program.templates[template.name] = template
    end

    def listen_to_me_very_carefully(name)
      # Create a function template
      template = ArnoldCFunctionTemplate.new(
        name,
        get_template(@@current_scope)
      )
      @@current_scope.push(template)
    end

    def i_need_your_clothes_your_boots_and_your_motorcycle(name)
      @@current_scope.last.parameters.push(name)
    end

    def give_these_people_air
      @@current_scope.last.return = true
    end

    def hasta_la_vista_baby
      template = @@current_scope.pop
      @@current_scope.last.templates[template.name] = template
    end

    def because_im_going_to_say_please(condition)
      conditional = ArnoldCConditional.new(
        condition,
        get_template(@@current_scope)
      )
      @@current_scope.push(conditional)
    end

    def bull_shit
      @@current_scope.last.switch_to_else
    end

    def you_have_no_respect_for_logic
      conditional = @@current_scope.pop
      conditional.end_if
      @@current_scope.last.body.push(conditional)
    end

    @@statements << def talk_to_the_hand(object, statement:)
      func = @@function_stack.search_for_function(statement.template.name)
      printer.print interpret_expression(object, func), "\n"
    end

    @@statements << def get_to_the_chopper(name, statement:)
      @@buffer = ArnoldCVariable.new(name)
    end

    @@statements << def here_is_my_invitation(object, statement:)
      func = @@function_stack.search_for_function(statement.template.name)
      @@buffer.value = interpret_expression(object, func)
    end

    @@statements << def enough_talk(statement:)
      raise UninitializedVariableError, @@buffer.name unless @@buffer.value

      func = @@function_stack.search_for_function(statement.template.name)
      func.closure[@@buffer.name] = @@buffer
      @@buffer = nil
    end

    @@statements << def ill_be_back(object = 0, statement:)
      func = @@function_stack.search_for_function(statement.template.name)
      func.stop_execution
      if func.should_return?
        func.return = interpret_expression(object, func)
      end
    end

    @@statements << def get_your_ass_to_mars(name, statement:)
      @@buffer = ArnoldCVariable.new(name)
    end

    @@statements << def do_it_now(name, *args, statement:)
      # invoker -> the function where the do_it_now statement is called
      # called_func -> the invoked function in func via the statement do_it_now
      invoker = @@function_stack.search_for_function(statement.template.name)

      # Create the invoked function via its template
      begin
        called_template = interpret_expression(name, invoker)
      rescue UndeclaredVariableError
        raise UndeclaredFunctionError, name
      end
      called_func = ArnoldCFunction.new(called_template)
      @@function_stack.push(called_func)

      # Store the variable, declared in get_your_ass_to_mars for later
      result_var = @@buffer if called_func.should_return?

      # Call the function, identified via name
      values = args.map { |object| interpret_expression(object, invoker) }
      called_func.execute(*values) 

      # If the function is non-void
      # save the result of the function execution to a variable
      if called_func.should_return?
        value = called_func.return_value
        unless value.is_a?(Integer) || value.is_a?(ArnoldCFunctionTemplate)
          raise FunctionDoesNotReturnError, name 
        end

        result_var.value = value 
        invoker.closure[result_var.name] = result_var
        @@buffer = nil
      end

      @@function_stack.pop # Remove the function from the function stack 
    end

    @@statements << def get_up(object, statement:)
      raise UninitializedVariableError, @@buffer.name unless @@buffer.value

      func = @@function_stack.search_for_function(statement.template.name)
      @@buffer.value += interpret_expression(object, func)
    end

    @@statements << def get_down(object, statement:)
      raise UninitializedVariableError, @@buffer.name unless @@buffer.value

      func = @@function_stack.search_for_function(statement.template.name)
      @@buffer.value -= interpret_expression(object, func)
    end

    @@statements << def youre_fired(object, statement:)
      raise UninitializedVariableError, @@buffer.name unless @@buffer.value

      func = @@function_stack.search_for_function(statement.template.name)
      @@buffer.value *= interpret_expression(object, func)
    end

    @@statements << def he_had_to_split(object, statement:)
      raise UninitializedVariableError, @@buffer.name unless @@buffer.value

      func = @@function_stack.search_for_function(statement.template.name)
      @@buffer.value /= interpret_expression(object, func)
    end

    @@statements << def i_let_him_go(object, statement:)
      raise UninitializedVariableError, @@buffer.name unless @@buffer.value

      func = @@function_stack.search_for_function(statement.template.name)
      @@buffer.value %= interpret_expression(object, func)
    end

    def no_problemo
      1
    end

    def i_lied 
      0
    end

    @@statements << def consider_that_a_divorce(object, statement:)
      raise UninitializedVariableError, @@buffer.name unless @@buffer.value

      func = @@function_stack.search_for_function(statement.template.name)
      first = @@buffer.value
      second = interpret_expression(object, func)
      condition = from_arnoldc_bool(first) || from_arnoldc_bool(second)
      if condition
        @@buffer.value = condition == from_arnoldc_bool(first) ? first : second
      else
        @@buffer.value = i_lied
      end
    end

    @@statements << def knock_knock(object, statement:)
      raise UninitializedVariableError, @@buffer.name unless @@buffer.value

      func = @@function_stack.search_for_function(statement.template.name)
      first = @@buffer.value
      second = interpret_expression(object, func)
      condition = from_arnoldc_bool(first) && from_arnoldc_bool(second)
      if condition  
        @@buffer.value = condition == from_arnoldc_bool(second) ? second : first 
      else
        @@buffer.value = i_lied
      end
    end

    @@statements << def let_off_some_steam_bennet(object, statement:)
      raise UninitializedVariableError, @@buffer.name unless @@buffer.value

      func = @@function_stack.search_for_function(statement.template.name)
      if @@buffer.value > interpret_expression(object, func)
        @@buffer.value = no_problemo
      else
        @@buffer.value = i_lied
      end
    end

    @@statements << def you_are_not_you_you_are_me(object, statement:)
      raise UninitializedVariableError, @@buffer.name unless @@buffer.value

      func = @@function_stack.search_for_function(statement.template.name)
      if @@buffer.value == interpret_expression(object, func)
        @@buffer.value = no_problemo
      else
        @@buffer.value = i_lied
      end
    end

    private

    def from_arnoldc_bool(arnoldc_bool)
      arnoldc_bool == 0 ? false : true
    end

    def interpret_expression(object, func) 
      value =
      if object.is_a?(Symbol) # i.e. object is a variable or function name
        if @@function_stack.search_for_template(func.template, object)
          # The name refers to a function template
          @@function_stack.search_for_template(func.template, object)
        elsif func.parameters.include? object
          # The variable requested is in the function's parameters
          func.parameter_values[object].value
        elsif func.closure.key? object
          # The requested variable is in the function's closure
          func.closure[object].value    
        else
          # The reference points to an undeclared variable
          raise UndeclaredVariableError, object
        end
      else
        object # object is a literal value
      end

      unless value.is_a?(Integer) || value.is_a?(ArnoldCFunctionTemplate)
        raise UninitializedVariableError, object
      end
      value
    end

    def get_template(scope)
      # Utilized during ArnoldC code interpretation
      func_index = scope.reverse.find_index do |expression|
        expression.is_a?(ArnoldCFunctionTemplate)
      end
      func_index ? scope[-(func_index+1)] : program
    end

    def program
      @@current_scope.first
    end

    def initialize_program
      program_template = ArnoldCFunctionTemplate.new(:__program__, nil)
      program_func = ArnoldCFunction.new(program_template)
      @@current_scope.push(program_func) 
    end

    def execute_program
      program.execute # Create top-level functions
      unless program.templates.key? :__main__
        raise UndeclaredFunctionError, :__main__
      end
      @@function_stack.main.execute # Execute main function
    end

    def reset_interpreter
      @@current_scope = []
      @@function_stack = ArnoldCFunctionStack.new 
      @@buffer = nil
    end
  end
end

