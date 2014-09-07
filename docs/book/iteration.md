# Iteration

Iteration in JavaScript has archaic syntax, reminiscent of C. ES5 introduced the `forEach`
function, which is nice, but requires a function call on every iteration, so it's often
slower. CoffeeScript uses simple for-loops.

    for x in [1..8]
        put 2 ** x

You can use the `then` operator to create one-liners ~ `for a in b then c`. CoffeeScript
also allows an expression to be followed by an iterator, where it will evaluate the
expression once for each iteration.

    put 2 ** x for x in [1..8]

You can also grab the index by providing an extra name to assign to.

    raceWinners = ["Ali", "Bob", "Caz"]
    put "#{index+1} ~ #{name}" for name, index in raceWinners

You can also use comprehensions for iterating over properties in objects by using the `of`
keyword, instead of `in`.

    staff =
        chef:   "Jane"
        barman: "John"

    put "The #{position}'s name is #{name}." for position, name of staff

---

Next Page: [Slicing](/docs/book/slicing.md)
