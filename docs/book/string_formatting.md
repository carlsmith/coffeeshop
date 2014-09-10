# String Formatting

CoffeeScript supports string formatting, where *double-quoted* strings can contain
`#{}` tags, each containing an expression to be interpolated.

    "two plus two is #{2 + 2}"

Multiline strings are fine too, and CoffeeScript allows for 'triple quotes', for when
you need a string that contains quotes [or doesn't, but you just like consistency].

    put "
        A simple, multiline string.
        "

Note that the indentation is resolved intuitively.

    put """
        A triple quoted, multiline string.
            With indented stuff.
        """

---

Next Page: [Iteration](/docs/book/iteration.md)
