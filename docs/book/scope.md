# Scope

JavaScript sucks at variable scope. CoffeeScript has no `var` keyword. All
assignments are *local*. If you want to create a global, you can just bind
to the `window` object explicitly

    func = ->
        x = 1         # local
        window.x = 1  # global

Lookups just start locally and move outwards.

---

Next Page: [Defining Functions](/docs/book/defining_functions.md)

[1]: http://en.wikipedia.org/wiki/CommonJS
