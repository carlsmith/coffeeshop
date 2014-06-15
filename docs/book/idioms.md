# Idioms

This page offers a small collection of the most useful CoffeeScript idioms.

# Comprehensions

CoffeeScript's iterator expressions abstract for-loops, and are written using the `<expression> for <name> in <sequence>` syntax.

    check(thing) for thing in things

    console.log "#{name}'s at index #{i}" for name, i in ['jon', 'jim', 'barry']

You can iterate over the pairs in an object using the `of` keyword instead of `in`.

    object = {one: 1, two: 2}
    alert "#{key} = #{value}" for key, value of object

## Maps

Note that you **must surround the comprehension with parens** if you want the array back, otherwise `result` gets assigned to on each iteration and just ends up equal to the last value.

    result = (item.name for item in array)

## Select

The `when` keyword is used to filter items in a comprehension.

    passed = (score for score in scores when score > 60)
    
    result = (item for item in array when item.name is "test")

CoffeeScript's comprehensions are very flexible:

    passed = []
    failed = []
    for score in [49, 58, 76, 82, 88, 90]
      (if score > 60 then passed else failed).push score

    (if score > 60 then passed else failed).push score for score in [49, 58, 76, 82, 88, 90]

## Membership

CoffeeScript allows use of the `in` keyword for membership tests on arrays.

    included = "test" in array

Sadly, that doesn't work on strings; you have to use `indexOf`, or hijack the bitwise operator `!!~`.

    string = "a boring test string"

    included = string.indexOf("test") isnt -1
    included = !!~ string.indexOf "test"

# Native Bindings

Using JavaScript libraries is exactly the same as using CoffeeScript libraries; they're the same thing. Using CoffeeScript with [jQuery](http://jquery.com) is especially elegant, due to the amount of callbacks in jQuery's API.

    $(".foo").click -> alert "Clicked!"

## Or Equals

CoffeeScript has an 'or equals' operator. In the following example, if `a` is falsey, `1` is assigned to `a`.

    a or= 1

Note that existential assignment is stricter: In the expression `a ?= 1`, `a` must specifically be `undefined` or `null` for the assignment to complete.
