# Slicing

Slicing is all about ranges, which are just arrays of orderly integers. CoffeeScript has
a simple syntax for defining ranges.

The expression `[5..10]` is equal to `[5, 6, 7, 8, 9, 10]`, and `[5...10]` is equal to
`[5, 6, 7, 8, 9]`. A triple dotted range does *not* include the last number.

    range = [1..3]  # [1, 2, 3]
    range = [1...3] # [1, 2]

You can also express a range when slicing an array.

    firstTwo = someArray[0..1]

In the example above, the variable `firstTwo` is assigned a new array that contains
the first two elements of `someArray`. You can also use slices for mutating a segment
of one array with another by assignment.

    someArray[3..5] = [-3, -4, -5]

You can slice strings too.

    firstTwo = "yoyo"[0..1]

Checking if a value exists in an array is fairly painful in JavaScript. In CoffeeScript,
it's not.

    1 in [1, 2, 3]

---

Next Page: [Existential Operations](/docs/book/existential.md)
