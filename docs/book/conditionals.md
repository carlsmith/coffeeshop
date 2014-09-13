# Conditionals

CoffeeScript's conditionals are about as simple as can be. They're written with the `if`
and `else` operators, and can be chained using `else if`. The conditional blocks are
delimited with indentation.

    fileType = (name) ->

        if name.endsWith ".md"
            return "Markdown"
        else if name.endsWith ".coffee"
            return "CoffeeScript"
        else
            return "Unknown"

You can one-liner a conditional using the `then` operator to delimit the boolean expression
from the conditional block. Don't use `then` after `else` as there's no boolean expression.

    fileType = (name) ->

        if name.endsWith ".md" then return "Markdown"
        else if name.endsWith ".coffee" then return "CoffeeScript"
        else return "Unknown"

## Everything's an Expression

CoffeeScript conditionals are expressions, evaluating to the last thing evaluated. Because
CoffeeScript functions also return the last thing evaluated, the `return` statements in the
above code are redundant. The function would implicitly return whatever the conditional
evaluates to.

    fileType = (name) ->

        if name.endsWith ".md" then "Markdown"
        else if name.endsWith ".coffee" then "CoffeeScript"
        else "Unknown"

Putting the `if` and `else` operators on new lines is also optional. You can one-liner the
entire conditional ~ `if a then b else if c then d else e`.

JavaScript's awkward ternary expression syntax, `truthy?yay:nay`, is gone, and would be
redundant with conditional expressions.

    a = if b then c else d
    foo(if a then b else c)

If any conditional evaluates without evaluating anything, then it evaluates to `undefined`.

    (if false then "foo") is undefined

## Skip Conditionals

CoffeeScript also adopted suffixed `if` expressions from Ruby. These expressions do not use
`else`. They simply evaluate or skip the expression before the `if` operator, based on the
truthiness of the expression that follows it.

    a = 1 if true
    put a if a is 1

---

Next Page: [String Formatting](/docs/book/string_formatting.md)
