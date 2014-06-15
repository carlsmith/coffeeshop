# Control Flow

The convention of optional parentheses continues with CoffeeScript's `if` and `else` keywords.

    if true == true
      "We're ok"

If the `if` statement is a one liner, you'll need to use the `then` keyword, so CoffeeScript knows when the block begins.
    
    if true != true then "Panic"

JavaScript's ternary syntax (`a?b:c`) is not supported, instead you should use `if`/`then`/`else` statements.

    if 1 > 0 then "all is well" else "give up all hope"

CoffeeScript also adopted the Ruby idiom of allowing suffixed `if` statements.
    
    alert "sub zero" if temps < 0

Instead of using the exclamation mark (`!`) for negation, you can *also* use the `not` keyword, which is nice.

    if not true then "Panic"

In the example above, we could also use CoffeeScript's `unless` keyword, which simple means the same as `if not`.

    unless true then "Panic"

CoffeeScript also introduces the `is` statement, which translates to `===` in JavaScript. You can also abbreviate `is not` to the alias `isnt`.

    if true is 1 then "Type coercion fail!"

    alert "WTF" if true isnt true

You may have noticed that CoffeeScript converts `==` operators into `===` and `!=` into `!==`, removing JavaScript's lesser comparison operators altogether.

---

Next Page: [String Formatting](/docs/book/string_formatting.md)