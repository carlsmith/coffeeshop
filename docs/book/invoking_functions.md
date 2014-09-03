# Invoking Functions

Functions can be invoked exactly as in JavaScript, with parenthesis after a function
expression, containing zero or more arguments.

    area = (x, y) -> x * y
    put(area(3, 4))

Like Ruby, CoffeeScript will also automatically call functions if they are invoked with
at least one argument, allowing you to pipe function by passing invokations to one another.
CoffeeShop's shell functions are designed to be used that way.

    put area 3, 4

You will need to use parenthesis sometimes to resolve ambiguity.

    cube = (x) -> square(x) * x

As in JavaScript, you can also the use `apply` and `call` methods to invoke functions.

---

Next Page: [Containers](/docs/book/containers.md)
