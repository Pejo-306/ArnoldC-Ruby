class OutOfBoundsError < StandardError 
  def message
    "Statement defined outside the bounds of a function."
  end
end

class UndeclaredVariableError < StandardError
  def initialize(var_name)
    super
    @var_name = var_name
  end

  def message
    "Undeclared variable '#{@var_name}' referenced."
  end
end

class UninitializedVariableError < StandardError
  def initialize(var_name)
    super
    @var_name = var_name
  end

  def message
    "Uninitialized variable '#{@var_name}' used."
  end
end

class UndeclaredFunctionError < StandardError
  def initialize(invoked_func_name)
    super
    @invoked_func_name = invoked_func_name
  end

  def message
    "Undeclared function '#{@invoked_func_name}' invoked."
  end
end

class FunctionDoesNotReturnError < StandardError
  def initialize(invoked_func_name)
    super
    @invoked_func_name = invoked_func_name
  end

  def message
    "Non-void function '#{@invoked_func_name}' does not return a result."
  end
end

