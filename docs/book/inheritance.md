# Inheritance

A class inherits from another class using the keyword `extends`. In the example below, `Parrot` inherits from `Animal`, inheriting all of its instance properties, such as `alive`.

    class Animal
      constructor: (@name) ->
    
      alive: ->
        false
    
    class Parrot extends Animal
      constructor: ->
        super("Parrot")
    
      dead: ->
        not @alive()
    

Note the use of the `super` function. This invokes the (overridden) inherited function; it invokes `Animal.constructor` in this case.

Because of inheritance, if `Parrot` lacks a `constructor` method, the constructor of the base class, `Animal`, gets invoked.

Classes are dynamic: Even if you add properties to a base class after a derived class has been created, the property will still be available to the derived class.

    
    class Animal
      constructor: (@name) ->
    
    class Parrot extends Animal
    
    Animal::rip = true
    
    parrot = new Parrot("Macaw")
    alert("This parrot is no more") if parrot.rip

> Note: Static properties are copied to subclasses, rather than inherited using prototype as instance properties are. This is due to implementation details with JavaScript's prototypal architecture, and is just a difficult problem to work around.