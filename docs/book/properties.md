# Properties

Adding instance properties to a class uses exactly the same syntax as adding properties to an object. Just make sure properties are indented correctly inside the class body.

    class Animal
      price: 5
    
      sell: (customer) ->
    
    animal = new Animal
    animal.sell(new Customer)

Remember, CoffeeScript locks the value of `this` to a particular context using a fat arrow function, ensuring that no matter what context a function is called in, it'll always execute inside the context it was created in. Support for fat arrows is extended to classes; using a fat arrow for an instance method ensures proper context, and that `this` is always equal to the current instance.

    class Animal
      price: 5

      sell: =>
        alert "Give me #{@price} shillings!"

    animal = new Animal
    $("#sell").click(animal.sell)

As demonstrated in the example above, proper context is especially useful in event callbacks. Normally the `sell` function would be invoked in the context of the `#sell` element, but by using fat arrows to define the `sell` method, the correct context is maintained; `this.price` equals `5`.

## Static properties

Within a class definition, `this` refers to the class object. In other words, you can set class properties by setting them directly on `this` (or just on `@`).

    class Animal
      @find = (name) ->
    
    Animal.find("Parrot")