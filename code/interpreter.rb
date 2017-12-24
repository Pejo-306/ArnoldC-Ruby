class ArnoldCVariable
  attr_reader :name
  attr_accessor :value

  def initialize(name, value = nil)
    @name = name
    @value = value
  end

  def to_s
    "ArnoldCVariable: #{@name} => #{@value}"
  end
end

class ArnoldCStatement
  attr_reader :name, :args, :template 

  def initialize(name, template, *args)
    # @name and @args are not used by the interpreter,
    # however they provide information about the statement to the reader 
    @name = name
    @args = args
    @template = template
    @code = nil
  end

  def code(&block)
    @code = block
  end

  def evaluate
    @code.call()
  end

  def to_s
    "ArnoldCStatement: #{@name}, #{@args.join(', ')}"
  end
end

class ArnoldCConditional
  attr_accessor :body

  def initialize(condition, template)
    @condition = condition
    @body = []
    @if_body = []
    @else_body = []
    @template = template
  end 

  def switch_to_else
    @if_body = @body[0..@body.length-1]
    @body = []
  end 

  def end_if
    if @if_body.empty? # i.e. an else clause is not present
      @if_body = @body[0..@body.length-1]
    else
      @else_body = @body[0..@body.length-1] 
    end
    @body = []
  end

  def evaluate
    # Transform @condition into a ruby bool
    func_stack = ArnoldCPM::Interpreter.class_variable_get(:@@function_stack)
    func = func_stack.search_for_function(@template.name)
    condition = ArnoldCPM.send :interpret_expression, @condition, func 
    condition = ArnoldCPM.send :from_arnoldc_bool, condition

    # Evaluate condition
    if condition 
      @if_body.each { |expression| expression.evaluate }
    else
      @else_body.each { |expression| expression.evaluate }
    end
  end
end

class ArnoldCFunctionTemplate
  attr_reader :name, :defined_within
  attr_accessor :body, :parameters, :templates, :return

  def initialize(name, defined_within)
    @name = name
    @defined_within = defined_within # The template this template is defined within
    @body = []
    @parameters = [] # Set only when the function is declared
    @templates = {} # All inner function templates
    @return = false
  end
  
  def to_s
    "ArnoldCFunctionTemplate: #{@name}(#{@parameters.join(', ')})"
  end
end

class ArnoldCFunction
  attr_reader :template, :name, :parameter_values, :defined_within
  attr_accessor :body, :parameters, :closure, :templates, :return 

  def initialize(template)
    @template = template
    @name = template.name 
    @defined_within = template.defined_within
    @body = template.body
    @parameters = template.parameters 
    @parameter_values = {}
    @closure = {}
    @templates = template.templates
    @return = template.return
    @should_stop = false
  end
  
  alias return_value return

  def should_return?
    @return
  end

  def stop_execution
    @should_stop = true
  end

  def execute(*values)
    # @parameter_values is a hash whose keys are parameter names
    # and whose parameter values are the values passed when calling
    # the function
    @parameter_values = @parameters.map.with_index do |param_name, index|
      [param_name, ArnoldCVariable.new(param_name, values[index])]
    end.to_h
    @body.each do |expression|
      break if @should_stop
      expression.evaluate
    end
  end
 
  def to_s
    "ArnoldCFunction: #{@name}(#{@parameters.join(', ')})"
  end
end

class ArnoldCFunctionStack
  attr_reader :stack

  def initialize
    @stack = []
  end

  def push(func)
    @stack.push(func)
  end

  def pop
    @stack.pop
  end

  def main
    search_for_function(:__main__)
  end

  def search_for_template(template, name)
    if template.defined_within.templates.key? name
      template.defined_within.templates[name]
    else
      template.templates[name]
    end
  end

  def search_for_function(name)
    index = @stack.reverse.find_index { |func| func.name == name }
    @stack[-(index+1)]
  end

  def list
    @stack.each { |func| puts func }
  end
end

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
      called_template = interpret_expression(name, invoker)
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
        result_var.value = called_func.return_value
        invoker.closure[result_var.name] = result_var
        @@buffer = nil
      end

      @@function_stack.pop # Remove the function from the function stack 
    end

    @@statements << def get_up(object, statement:)
      func = @@function_stack.search_for_function(statement.template.name)
      @@buffer.value += interpret_expression(object, func)
    end

    @@statements << def get_down(object, statement:)
      func = @@function_stack.search_for_function(statement.template.name)
      @@buffer.value -= interpret_expression(object, func)
    end

    @@statements << def youre_fired(object, statement:)
      func = @@function_stack.search_for_function(statement.template.name)
      @@buffer.value *= interpret_expression(object, func)
    end

    @@statements << def he_had_to_split(object, statement:)
      func = @@function_stack.search_for_function(statement.template.name)
      @@buffer.value /= interpret_expression(object, func)
    end

    @@statements << def i_let_him_go(object, statement:)
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
      func = @@function_stack.search_for_function(statement.template.name)
      if @@buffer.value > interpret_expression(object, func)
        @@buffer.value = no_problemo
      else
        @@buffer.value = i_lied
      end
    end

    @@statements << def you_are_not_you_you_are_me(object, statement:)
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
      if object.is_a? Symbol # i.e. object is a variable or function name
        if @@function_stack.search_for_template(func.template, object)
          # The name refers to a function template
          @@function_stack.search_for_template(func.template, object)
        elsif func.parameters.include? object
          # The variable requested is in the function's parameters
          func.parameter_values[object].value
        else
          # The requested variable is in the function's closure
          func.closure[object].value    
        end
      else
        object # Object is a literal value
      end
    end

    def get_template(scope)
      # Utilized during ArnoldC code interpretation
      func_index = scope.reverse.find_index do |expression|
        expression.is_a? ArnoldCFunctionTemplate
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
      @@function_stack.main.execute # Execute main function
    end

    def reset_interpreter
      @@current_scope = []
      @@function_stack = ArnoldCFunctionStack.new 
      @@buffer = nil
    end
  end
  
  extend Interpreter

  class << self
    def method_missing(name, *args, &block)
      # Return name if this is an ArnoldC variable or function name
      return name if args.empty? && !block_given?
      super(name, *args, &block)
    end

    def printer
      @@printer
    end

    def printer=(printer)
      @@printer = printer 
    end

    def totally_recall(&code)
      initialize_program
      instance_eval(&code)
      execute_program
      reset
    end

    private def reset
      reset_interpreter
    end
  end
end

