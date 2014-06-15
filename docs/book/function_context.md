# Function Context

Context changes are rife within JavaScript, especially with event callbacks, so CoffeeScript provides a few helpers to manage this. One such helper is made available through fat arrow functions, using `=>` instead of `->`.

Using the fat arrow instead of the thin arrow ensures that the function context will be bound to the local one. For example:

    this.clickHandler = -> alert "clicked"
    element.addEventListener "click", (e) => this.clickHandler(e)
    
The reason you might want to do this, is that callbacks from `addEventListener` are executed in the context of the `element`, where `this` equals the element. If you want to keep `this` equal to the local context, without doing a `self = this` dance, fat arrows are the way to go.

This binding idea is a similar concept to [jQuery's `proxy` method][1] or [ES5's `bind`][2].

---

Next Page: [Containers](/docs/book/containers.md)

[1]: http://api.jquery.com/jQuery.proxy/
[2]: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Function/bind