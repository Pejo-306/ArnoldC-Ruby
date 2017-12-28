require_relative 'arnoldcpm/interpreter'

module ArnoldCPM
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
    ensure
      reset_interpreter
    end
  end
end

