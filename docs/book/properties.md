# Class Properties

Adding properties to a class uses the same syntax as defining object properties. This is
used to add class properties. Instance properties are defined in the constructor.

    class Animal
        constructor: (@name, @kind) ->
        identify: -> put "#{@name} is a #{@kind}."

    animal = new Animal("Suzi", "Dog")
    animal.identify()

## Where is `this @`

CoffeeScript locks the value of `this` to the current context inside fat arrow functions.
Using a fat arrow ensures that no matter what context a function is *called* in, `this`
will be whatever `this` was in the scope the function was *defined* in. This is useful
because JavaScript changes the context when a function is used as a callback, so the
value of `this` changes, depending on where the function is called.

Using a fat arrow for a method ensures that `this` is always the instance of the class
the invocation is bound to. Python's `self`.

For example, the following will not work as `animal.identify` was defined with a thin
arrow, meaning that, once it's passed as a callback to `peg`, `this` is `undefined`,
not the instance of `Animal` that `indentify` seems to be bound to.

    peg "click here", (div) ->
        div.click animal.identify
        div.css cursor: "pointer"

Redefining the method with a fat arrow ensures that `this` is always the current instance,
no matter where `indentify` gets called.

    class Animal
        constructor: (@name, @kind) ->
        identify: => put "#{@name} is a #{@kind}."

    animal = new Animal("Jim", "Shark")

If you run this code, then run the `peg` invocation again, you'll see that `this` is now
what you expect it to be.
