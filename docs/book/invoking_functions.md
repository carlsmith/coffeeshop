# Invoking Functions

Functions can be invoked exactly as in JavaScript, with parenthesis after a function
expression, containing zero or more arguments.

    area = (x, y) -> x * y
    put(area(3, 4))

Like Ruby, CoffeeScript automatically calls functions if they are invoked with arguments.
This allows you to pipe functions by passing invocations to one another.

    put area 3, 4

You will need to use parenthesis sometimes to resolve ambiguity.

    cube = (x) -> square(x) * x

As in JavaScript, you can also the use `apply` and `call` methods to invoke functions.

## The `do` Operator

If you want to call a function with no arguments, just use empty parens or the `do`
operator.

    f = -> put true
    do f
    f()

You can use `do` to invoke a function literal too, using default arguments to parameterise
the function.

    do (a=1) -> put a + 1

The `do` operation evaluates as the function call, so the following expression does the
same as the expression above.

    put do (a=1) -> a + 1

---

[Function Context](/docs/book/function_context.md)
