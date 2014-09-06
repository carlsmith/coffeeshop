# Containers

CoffeeScript has two container types, objects and arrays. To avoid ambiguity ~ because
everything is an object ~ plain objects are often referred to as hashes or maps. In these
docs, they're referred to as hashes, and called chits if they're JSON serialisable.

## Hashes

Hashes can be specified exactly as in JavaScript, with key:value pairs wrapped in curly
braces. However, like with function invocation, CoffeeScript makes the braces optional.

    put one: 1, two: 2

You can also use indentation and new lines instead of comma separation.

    object =
        one: 1
        two: 2

You can pass a hash as the last argument to a function by indenting it. This is a nice
syntax for passing an options argument.

    jQuery.ajax
        url: "/docs/home.md"
        success: (response) -> put response

## Arrays

Arrays are also able to be written with whitespace instead of commas, although the square
brackets are always required. CoffeeScript will fix trailing commas for you, both extra
and missing ones.

    bools = [
        "foo",
        "bar",
        ]

    tictactoe = [
        1, 1, 2
        0, 2, 1
        2, 1, 2
        ]

---

Next Page: [Conditionals](/docs/book/conditionals.md)
