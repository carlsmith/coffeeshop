# Defining Functions

CoffeeScript has no `function` statement; it uses a thin arrow, `->`, instead. There are
no function definitions either, only function expressions. If you want to 'define' a
function, you assign the function expression to a name.

    getAuth = -> get "coshGitHubAuth"

    square = (x) -> x * x

The `square` function here takes an argument, `x`. Arguments are named in parenthesis
before the arrow. The body of the function follows the arrow, on the same line or
indented on multiple lines.

The last expression evaluated will be implicitly returned, unless the `return` statement is
used to return from the function immediately instead.

    size = (x, y, z=1) ->
        for dimension in [x, y, z]
            return NaN if dimension < 0
        x * y * z

    put size 5, 10
    put size 5, 10, 20

Note that the argument `z` is given a default value of `1` in the example above. You can
also use splats (`...`) to gather arguments into an array.

    sum = (args...) ->
        tally = 0
        args.forEach (x) -> tally += x
        tally

    put sum 1, 2, 3, 4, 5

> Note that `args` is not a JavaScript `arguments` object; it's just an array.

You can also gather spare arguments.

    f = (x, args...) -> args.forEach (y) -> put x * y

CoffeeScript's function syntax is especially elegant when you just need a lambda.

    jQuery.get "/docs/home.md", (doc) -> put doc

---

Next Page: [Invoking Functions](/docs/book/invoking_functions.md)
