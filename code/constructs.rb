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

