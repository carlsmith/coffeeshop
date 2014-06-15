# String Formatting

CoffeeScript supports string formatting, where *double-quoted* strings can contain `#{}` tags, which contain expressions to be interpolated.

    favourite_color = "Blue. No, yel..."
    question = "Bridgekeeper: What... is your favourite color?
                Galahad: #{favourite_color}
                Bridgekeeper: Wrong!
                "

Note that multiline strings are fine too.

---

Next Page: [Iteration](/docs/book/iteration.md)