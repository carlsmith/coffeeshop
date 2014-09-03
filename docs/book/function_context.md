# Function Context

JavaScript has issues with context, especially with event callbacks. CoffeeScript
provides fat arrow functions, that use `=>` instead of `->`, to help with that.

Using the fat arrow instead of the thin arrow ensures that the function context will
be locally bound. For example:

    this.clickHandler = -> alert "clicked"
    element.addEventListener "click", (element) => this.clickHandler(element)

Because callbacks from `addEventListener` are executed in the context of `element`, `this`
equals the element. If you want to `this` bound to its original context, without having to
stash `this` with a `self = this` dance, use fat arrows.

This binding idea is a similar concept to [jQuery's `proxy` method][1] or
[ES5's `bind`][2].

---

[1]: http://api.jquery.com/jQuery.proxy/
[2]: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Function/bind
