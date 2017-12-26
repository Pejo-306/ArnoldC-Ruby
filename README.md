# ArnoldC-Ruby
This project is a simple implementation of ArnoldC. The latter is an
esoteric programming language whose statements are some of Arnold
Schwarzenegger's quotes. The Interpreter itself is written in Ruby.

Be aware that this project only implements the most essential aspects of
the language ArnoldC. Continue reading the documentation for further
elaboration.

# Table of contents
* [About the language ArnoldC](#about-the-language-arnoldc)
  * [The main function](#the-main-function)
  * [Printing](#printing)
  * [Types](#types)
  * [Variables](#variables)
  * [Operations on variables](#operations-on-variables)
    * [Arithmetics](#arithmetics)
    * [Logical operations](#logical-operations)
    * [Comparison](#comparison)
  * [Conditionals](#conditionals)
  * [Functions](#functions)
    * [Declaration](#declaration)
    * [Invocation](#invocation)
    * [Nested functions](#nested-functions)
    * [Recurssion](#recurssion)
* [Implementation in Ruby](#implementation-in-ruby)
  * [Constructs](#constructs)
  * [The interpreter](#the-interpreter)
  * [Errors](#errors)
  * [Source code files](#source-code-files)
* [Personal motivation](#personal-motivation)

# About the language ArnoldC
Most languages implement concepts such as variables, functions, conditional,
etc. ArnoldC also supports said features. Further details are listed below.

## The main function
Every ArnoldC program declares a main function which is executed immediately
after all top-level functions have been declared. Its body is enclosed
between two keywords as shown below:

```ruby
its_showtime
    # Main function body
you_have_been_terminated
```

## Printing
Program output is written via the following statement:

```ruby
talk_to_the_hand 42
```

## Types
This implementation is not statically typed. There are only two types:
non-negative integers and functions. All operations except function
invocation and equality comparison work solely on numbers.

## Variables
Variables can store information for later use in the program's flow. They
can store numbers as well as functions (more on that later). They are declared
in the following fashion:

```ruby
get_to_the_chopper _var_name  # declares the variable
    here_is_my_invitation 42  # sets the initial value of the variable
enough_talk  # ends the variable declaration
```

Variables must be initialized i.e. it is not possible for variables to not
contain a value (a number or a function).

They can later be referenced in other statements via their variable name:

```ruby
talk_to_the_hand _var_name  # prints 42
```

## Operations on variables
Evaluation of different operations such as arithmetics require that an
initial value be set to the mentioned variable. Furthermore, operations must
be executed within the variable's declaration. After the variable has been
declared its value can not be altered.
All operations have equal priority.

### Arithmetics
There are five arithmetic operations:

```ruby
get_up 42  # addition
get_down 42  # subtraction
youre_fired 42  # multiplication
he_had_to_split 42  # division
i_let_him_go 42  # modulo division
```

Example usage:

```ruby
get_to_the_chopper _var
    here_is_my_invitation 42
    get_up 8
    he_had_to_split 2
enough_talk

talk_to_the_hand _var  # outputs 25
```

### Logical operations
In ArnoldC 0 is considered as untruth while all other values are considered
to be truth.

There are two logical constants for 0 and 1 (respectively untruth and truth):

```ruby
i_lied  # equal to 0 (untruth)
no_problemo  # equal to 1 (truth)
```

This implementation supports only the logical operations **AND** and **OR**.

```ruby
knock_knock 1  # logical AND
consider_that_a_divorce  # logical OR
```

**AND** returns the operand which evaluates to untruth (if both operands
evaluate to untruth then both their values are equal to 0 so it does not
matter which operand is returned).

```ruby
get_to_the_chopper _var
    here_is_my_invitation 0
    knock_knock 1
enough_talk

talk_to_the_hand _var  # outputs 0
```

**OR** returns the first operand which evaluates to truth (if both operands
evaluate to untruth then both their values are equal to 0 so it does not
matter which operand is returned).

```ruby
get_to_the_chopper _var
    here_is_my_invitation 42
    consider_that_a_divorce 21
enough_talk

talk_to_the_hand _var  # outputs 42
```

Logical **NOT** and **XOR** are no supported by this project.

### Comparison
Only two comparison operators are implemented in this interpreter: greater than
(>) and equal to (==). Both return either 0 (false) or 1 (true).

```ruby
let_off_some_steam_bennet 42  # > 42
you_are_not_you_you_are_me 42 # == 42
```

The equality operator also works on functions by evaluating their identity
(i.e. are they the same Ruby object in memory). 

Example usage:

```ruby
get_to_the_chopper _var
    here_is_my_invitation 42
    let_off_some_steam_bennet 21
enough_talk

talk_to_the_hand _var  # outputs 1 
```

## Conditionals
Conditionals are supported by the ArnoldC Interpreter. There are three keyword
phrases which are used to define conditionals.

```ruby
because_im_going_to_say_please _condition
    # body which is executed if the condition evaluates to truth
bull_shit
    # body which is executed if the condition evaluates to untruth
you_have_no_respect_for_logic  # ends the definition of the conditional
```

The else clause (i.e. 'bull\_shit') can be omitted in which case no code will
be executed if the condition does not evaluate to truth.

Nested conditionals are also supported.

```ruby
get_to_the_chopper _condition
    here_is_my_invitation no_problemo
enough_talk

because_im_going_to_say_please _condition
    because_im_going_to_say_please _condition
        talk_to_the_hand 11
    bull_shit
        talk_to_the_hand 22
    you_have_no_respect_for_logic
    talk_to_the_hand 33
bull_shit
    because_im_going_to_say_please _condition
        talk_to_the_hand 44
    you_have_no_respect_for_logic
    talk_to_the_hand 55
you_have_no_respect_for_logic

# outputs 11 and 33
```

## Functions 
Alongside numbers functions are the other type supported in ArnoldC.

### Declaration
Functions are declared via the statements the following statements:

```ruby
listen_to_me_very_carefully _func  # declares a function named '_func'
    # function body
hasta_la_vista_baby  # ends the function declaration
```

By default all functions are void i.e. they do not return a value. Functions
can be declared as non-void via the statement 'give\_these\_people\_air'.
Non-void functions must return a value via the statement 'ill\_be\_back'.

Example:

```ruby
listen_to_me_very_carefully _func
give_these_people_air
    ill_be_back 42  # returns 42
hasta_la_vista_baby
```

If a return value has not been specified, the function will return 0 by
default.

Void functions can also contain a return statement but the actual value
specied to be returned is ignored by the interpreter.

The return statement breaks the control flow of the function which means
that all statements after the executed return statement are ignored and not
evaluated.

```ruby
listen_to_me_very_carefully _print_something
    talk_to_the_hand 42
    ill_be_back
    talk_to_the_hand 21  # is not executed
hasta_la_vista_baby

# outputs 42
```

Functions can also have their own parameters which can be referenced in the
function's body:

```ruby
listen_to_me_very_carefully _times_two
i_need_your_clothes_your_boots_and_your_motorcycle _x  # declare a parameter
give_these_people_air
    get_to_the_chopper _x_times_two
        here_is_my_invitation _x  # parameter value accessed here
        youre_fired 2
    enough_talk

    ill_be_back _x_times_two
hasta_la_vista_baby
```

### Invocation
Functions can be invoked via the keyword phrase 'do\_it\_now' followed by said
function's name. If the funcion defines any parameters they are passed
successively by seperating them with commas. If a non-void function is
invoked, its return value must be assigned to a variable via the statement
'get\_your\_ass\_to\_mars'.

Examples:

```ruby
# function invocation with no parameters
do_it_now _some_func

# function invocation with parameters
do_it_now _print, 42

# function invocation with return value
get_your_ass_to_mars _result
do_it_now _times_two, 42
```

### Nested functions
Functions can be defined within other functions. After that the inner functions
can be invoked and returned within the outer function.

```ruby
listen_to_me_very_carefully _outer
give_these_people_air
    listen_to_me_very_carefully _inner
        talk_to_the_hand 42
    hasta_la_vista_baby

    do_it_now _inner  # prints 42
    ill_be_back _inner  # returns the inner function which can be invoked elsewhere
hasta_la_vista_baby
```

Note that a function's inner functions are not accessible to other functions
that share the former's scope. Continuing the previous example, the following
code is invalid and will result in an error

```ruby
# ... previous example code

its_showtime
    # ... code
    do_it_now _inner  # fails to execute this statement
    # ... code
you_have_been_terminated
```

A function does not redefine its inner functions when invoked multiple times.
This behaviour can be illustrated by continuing the first example:

```ruby
# ... code from first example

its_showtime
    get_your_ass_to_mars _first_invocation
    do_it_now _outer

    get_your_ass_to_mars _second_invocation
    do_it_now _outer

    get_to_the_chopper _identical_inner_functions
        here_is_my_invitation _first_invocation
        you_are_not_you_you_are_me _second_invocation
    enough_talk

    talk_to_the_hand _identical_inned_functions  # prints 1
you_have_been_terminated
```

### Recurssion
The ArnoldC Interpreter also supports recurssion which is the only way for
cycling in ArnoldC.

```ruby
listen_to_me_very_carefully _print_to_limit
i_need_your_clothes_your_boots_and_your_motorcycle _number
i_need_your_clothes_your_boots_and_your_motorcycle _limit
    talk_to_the_hand _number

    get_to_the_chopper _number_plus_one
        here_is_my_invitation _number
        get_up 1
    enough_talk

    get_to_the_chopper _condition
        here_is_my_invitation _limit
        let_off_some_steam_bennet _number_plus_one
    enough_talk

    because_im_going_to_say_please _condition
        do_it_now _print_to_limit, _number_plus_one, _limit
    you_have_no_respect_for_logic
hasta_la_vista_baby

its_showtime
    do_it_now _print_to_limit, 1, 5
you_have_been_terminated

# outputs 1, 2, 3 and 4
```

# Implementation in Ruby
This project implements a Ruby module ArnoldCPM which has a few specifics
explained below.

First, before any ArnoldC code can be evaluated a printer must be defined. The
latter is a Ruby class which defines its own 'print' method that outputs data.
The class 'Kernel' is suitable to use in most cases.

The crucial method which evaluates ArnoldC code is 'totally\_recall'. It
receives a block that contains the source code for an ArnoldC program. It is
appropriate to mention here that ArnoldC code is actually valid Ruby code i.e.
ArnoldC expression are internally Ruby methods which interact with one
another to exhibit the expected behaviour of ArnoldC code.

## Constructs
The structures used to interpret ArnoldC code are the following: variables,
statements, conditionals, function templates, functions, and a function stack.
They are declared in *'code/constructs.rb'*.

### Variables
ArnoldC variables are instances of the class ArnoldCVariable. The latter has
instance variables that contain the name of the ArnoldC variable and the value
which the variable holds.
 
### Statements
An ArnoldC statement is a structure which executes some Ruby code and is
attached to a function (e.g. 'talk\_to\_the\_hand' prints a value). Statements
also contain information themselves such as its name and the expression which
once evaluated yield values used by the statement. However, said information
is actually not utilized by the interpreter and only serves to aid the readers
who wish to understand the Ruby implementation of the interpreter.

### Conditionals
Conditionals contain two seperate bodies - one that is executed if the
condition is true and the other which is executed if the condition evaluates
to untruth. The bodies themselves are a collection of ordered statements and
are executed in sequence. Conditionals themselves are attached to a function's
body.

### Functions and Function templates
Templates are in essence a function's definition. The former contain information
about the the name of the function, its parameters' names, and its body which
is a collection of ordered statements and conditionals, etc. Templates can be
stored in other templates which is how the behaviour of nested functions is
achieved. However, it should be noted that templates do not have a closure
of inner variables and parameter values i.e. values determined when a function
is invoked. While templates have a body of statements they can not be
executed.

Function templates are later used to instantiate the functions themselves which
is accomplished only when a function is invoked. The new function instances
contain all the information that templates contain. However, functions also
contain a closure (a collection of all of its inner variables), parameter
values, return value, a method which executes the body of the function, etc.

### Function stack
The function stack piles on top of one another function instances. The topmost
function is the one currently being executed. This behaviour is required to
implement recurssion where multiple instaces of the same declared function are
created (i.e. multiple functions are created with the same template).

## The interpreter
The module that contains all ArnoldC expressions is ArnoldCPM::Interpreter.
They are defined as normal Ruby methods. The interpreter extends ArnoldCPM
which means that all interpreter methods become ArnoldCPM's class methods.
Most ArnoldC expressions are considered statements which means that they
define some behaviour which is appended to a function's body for evaluation at
a later stage. This is accomplished in Ruby by keeping said behaviour in a
statement's instance variable.

Expressions which do not create statements are those which are utilized in the
declaration of conditionals and functions. These expressions add a new block in
which statements are stored.

A new function stack is created for each ArnoldC program that is executed.
ArnoldCPM::Interpreter has a class variable which stores that function stack.
At the bottom of the stack lay the function whose name is '\_\_program\_\_'. It
encompases all other functions defined within it which are the program's
top-level functions (e.g. the main function). When \_\_program\_\_ is executed
it declares all top-level functions after which the recently declared main
function (whose name is '\_\_main\_\_') is instantiated, added to the top of
the stack and executed.

All functions are created using their declared templates only when they are
invoked. Each function stores its own parameter values and its own closure.
The latter contains all variables declared within said function. Both can be
referenced in the function's body by name.

## Errors
Custom Ruby exceptions are defined in *'code/errors.rb'*. They are raised when
undefined ArnoldC behaviour is used such as referencing an undeclared function,
using an uninitialized variable in operations, etc.

## Source code files
An ArnoldC program's source code can be stored in a text file. These files
can be opened and executed by the script *'execute.rb'*. It can be run with
the following command:

```bash
$ ruby execute.rb [filepath]
```

Example:

```bash
$ ruby execute.rb files/hello_world.arnoldc
```

# Personal motivation
This project is meant to give me experience using git as well as Ruby. It is
my first project that employs both utilities. Not only that but it is my first
fully finished project (or at least developed to a state at which it could be
utilized).

Another reason why I was motivated to continue working was the theme of the
project - developing not only my own interpreter but also implementing an
esoteric programming language.

