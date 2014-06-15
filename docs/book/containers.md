# Containers

Object literals can be specified exactly as in JavaScript, with a pair of braces and key/value statements. However, like with function invocation, CoffeeScript makes the braces optional. In fact, you can also use indentation and new lines instead of comma separation.

    object = {one: 1, two: 2}
    object = one: 1, two: 2
    object = 
      one: 1
      two: 2

Of course, this works with arguments to function calls too.

    User.create({name: "John"})
    User.create(name: "John")

Likewise, arrays can use whitespace instead of comma separators, although the square brackets (`[]`) are still required.

    array = [1, 2, 3]
    
    array = [
      1
      2
      3
    ]
    
The following examples are valid too. CoffeeScript will strip the trailing comma in the first assignment, and add them in for the second.

    array = [
      1,
      2,
      3,
    ]
    
    array = [
      1, 2, 3
      4, 5, 6
      7, 8, 9
    ]

---

Next Page: [Control Flow](/docs/book/control_flow.md)