# Iterators and Comprehensions

CoffeeScript's iterators abstract for-loops, and are written using the `for <name> in <sequence>` syntax.

    for thing in things
      check(thing)

You can also use an invoking iterator.

    check(thing) for thing in things

You can get the index of the iteration with the `for <name>, <index> in <sequence>` syntax.

    console.log "#{name}'s at index #{i}" for name, i in ['jon', 'jim', 'barry']

You can iterate over an object's key:value pairs using the `of` keyword instead of `in`.

    object = {one: 1, two: 2}
    alert "#{key} = #{value}" for key, value of object

## Comprehensions

Note that you *must surround the iterator expression with parens* to generate an array, otherwise `result` gets assigned to on each iteration and just ends up equal to the last value.

    result = (item.name for item in array)

The `when` keyword is used to filter items in a comprehension.

    passed = (score for score in scores when score > 60)
    
    result = (item for item in array when item.name is "test")

CoffeeScript's comprehensions are very flexible:

    passed = []
    failed = []

    for score in [49, 58, 76, 82, 88, 90]
      (if score > 60 then passed else failed).push score

    (if score > 60 then passed else failed).push score for score in [49, 58, 76, 82, 88, 90]
