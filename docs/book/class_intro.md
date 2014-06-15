# Introducing Classes

All you need to define a custom class is the `class` keyword followed by a name for the new class, capitalized by convention..

    class Animal

In the example above, a custom class named `Animal` is created. You could now use `Animal` as a constructor with the `new` operator.

    animal = new Animal()

You'll often want to customize the class constructor (the method that gets invoked upon instantiation). You can do this by defining a `constructor` method.

    class Animal
      constructor: (name, kind) ->
        @name = name
        @kind = kind

Note that `@` is bound to `this`, so `@name` is shorthand for `this.name`.

Like in the last example, it's common to set instance properties to the names of the arguments. In CoffeeScript, if a parameter-
5is prefixed with `@`, an instance property is automatically created with that name and the argument is used as it's value. The above example could be written as follows:

    class Animal
      constructor: (@name, @kind) ->
 
As you'd expect, any arguments passed on instantiation are proxied to the constructor function.

    polly = new Animal("Polly", "Parrot")
    alert "#{polly.name} the #{polly.kind} says Hi."

---

Next Page: [Properties](/docs/book/properties.md)