# Function Context

JavaScript has issues with context, especially with event callbacks. CoffeeScript
provides fat arrow functions, that use `=>` instead of `->`, to help with that.

Using the fat arrow instead of the thin arrow ensures that the function context will
be locally bound. That is to say that `this` will point to what `this` was when the
function was defined, not the context the function's executed in.

This binding idea is a similar concept to [jQuery's `proxy` method][1] or
[ES5's `bind`][2].

---

[1]: http://api.jquery.com/jQuery.proxy/
[2]: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Function/bind
