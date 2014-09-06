# Introducing Classes

All you need to define a custom class is the `class` keyword followed by a name for the new
class, capitalised by convention.

    class Animal

In the example above, a custom class named `Animal` is created. You could now use `Animal`
as a constructor with the `new` operator.

    animal = new Animal()

To customise the class constructor ~ the method that gets invoked on instantiation ~ you
define a `constructor` method.

    class Animal
      constructor: (name, kind) ->
        @name = name
        @kind = kind

Note that `@` is bound to `this`, so `@name` is shorthand for `this.name`.

As above, it is common to see constructor functions that create properties with the same
names as the arguments. In CoffeeScript, if an *argument* name is prefixed with an `@`, the
argument's value is automatically bound to a property with the argument's name (minus the
`@`). The above example could have been written as:

    class Animal
      constructor: (@name, @kind) ->

As you'd expect, arguments are passed to the constructor function in the constructor call.

    polly = new Animal("Polly", "Parrot")
    "#{polly.name} is a #{polly.kind}."

---

Next Page: [Properties](/docs/book/properties.md)
