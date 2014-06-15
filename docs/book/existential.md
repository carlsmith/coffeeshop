# The Existential Operator

Using `if` for `null` checks in JavaScript is common, but has a few pitfalls in that empty strings and zero are both coerced into `false`, which can catch you out. CoffeeScript's existential operator `?` returns true unless a variable is `null` or `undefined`, similar to Ruby's `nil?`.
    
    praise if brian?

You can also use the existential operator in place of the `||` operator:

    velocity = southern ? 40

If you're using a `null` check before accessing a property, you can skip that by placing the existential operator right before the property.

    blackKnight.getLegs()?.kick()

Similarly you can check that a property is actually a function, and callable, by placing the existential operator right before the parens. If the property doesn't exist, or isn't a function, the function just doesn't get called.

    blackKnight.getLegs().kick?()
