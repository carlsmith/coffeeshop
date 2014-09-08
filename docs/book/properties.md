# Class Properties

Adding properties to a class uses the same syntax as defining object properties. This is
used to add class properties. Instance properties are defined in the constructor.

    class Animal
        constructor: (@name, @kind) ->
        identify: -> put "#{@name} is a #{@kind}."

    animal = new Animal("Suzi", "Dog")
    animal.identify()

## Where is `this`

CoffeeScript locks the value of `this` to a particular context using a fat arrow function,
ensuring that no matter what context a function is *called* in, it'll always execute inside
the context it was *created* in. Support for fat arrows is extended to classes. Using a fat
arrow for a method ensures that `this` (and `@`) is always the current instance.

The following will not work, as `animal.identify` will not retain the context of `this`, as
it was defined with a thin arrow. Click the output to see.

    peg "click this", (div) ->
        div.click animal.identify
        div.css cursor: "pointer"

Redefining the method with a fat arrow ensures that `this` is always the current instance,
no matter where `indentify` gets called.

    class Animal
        constructor: (@name, @kind) ->
        identify: => put "#{@name} is a #{@kind}."

    animal = new Animal("Jim", "Shark")
    peg "click this", (div) ->
        div.click animal.identify
        div.css cursor: "pointer"
