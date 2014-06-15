# Invoking Functions

Functions can be invoked exactly as in JavaScript, with parens `()`, or by using the `apply` and `call` methods. However, like Ruby, CoffeeScript will automatically call functions if they are invoked with at least one argument.

    a = "Howdy!"
    
    alert a
    alert(a)
    
    alert inspect a
    alert(inspect(a))

Although parenthesis is optional, it's recommended wherever it's not immediately obvious what's being invoked, and with which arguments. In the last example, wrapping at least the `inspect` invocation in parens helps to make the code clear.

    alert inspect(a)

If you don't pass any arguments with an invocation, CoffeeScript has no way of working out if you intend to invoke the function, or just express it. In this respect, CoffeeScript's behavior differs from Ruby (which always invokes references to functions), and is more similar to Python's (which only does so with property methods).

    # assuming that bar's a function...
    foo = bar # foo now references the function bar
    foo = bar() # foo now references the value returned by a call to bar

---

Next Page: [Function Context](/docs/book/function_context.md)