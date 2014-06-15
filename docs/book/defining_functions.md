# Defining Functions

CoffeeScript has no `function` statement. It uses a thin arrow (`->`) instead.
Functions can be one-liners or indented on multiple lines.

The last expression evaluated is implicitly returned unless the `return`
statement is used to return from the function abruptly. Also note that, you do
not need to write empty parenthesis for a function with no arguments.

    hi = -> "hello world"

## Arguments

You specify any arguments in parentheses *before* the arrow.

    square = (x) -> x * x

CoffeeScript supports default arguments too, for example:

    times = (x, y=2) -> x * y

You can also use 'splats' [`...`] to gather arguments into an array.

    sum = (args...) ->
        tally = 0
        args.forEach (n) -> tally += n
        tally

    put sum 1, 2, 3, 4, 5

> Note that `args` is not a JavaScript `arguments` object; it's just an array.

In the example above, `args` is an array of all the arguments passed to the
function. You could also do something like the following to gather *spare
arguments*.

    f = (x, args...) -> args.forEach (y) -> put x * y


## Inline Function Expressions

Functions are often used inline, as callbacks and so on. CoffeeScript uses the
exact same syntax for this case.

    jQuery.get "/docs/home.md", (doc) -> put doc

---

Next Page: [Invoking Functions](/docs/book/invoking_functions.md)
