# Output Functions

The are four output functions. Three append stuff to the board; one clears it.

- `put` Appends a pretty printed evaluation of any expression to the board.
- `peg` Appends a string of Markdown, a DOM node or a jQuery object to the board.
- `print` Loads and pegs a resource to the board.
- `clear` Clears the board.

## Introducing the `put` Function

The `put` function takes a single argument, any object, and pretty prints it.
Strings are printed in green; everything else is pink.

    put key for key of localStorage

When you enter code in the shell, the last value to be evaluated is put
automatically, so you often don't need to call `put` yourself.

## Introducing the `peg` Function

The `peg` Function appends DOM stuff to the board. It accepts Markdown
strings.

    peg """
        # A Markdown Page

        - with bullet points and *emphasised text*
        - some **bold text** and some `inline code`
        """

Anything within tags in a Markdown document is not compiled, so you can have a Markdown
string which is all one `div` element, allowing for pure HTML Markdown strings.

The `peg` function also accepts DOM nodes and jQuery objects.

    peg $("<img>").attr height: 256, src: "/images/logo.png"

## Tweaking `put` and `peg` calls.

The first argument to `put` and `peg` is internally normalised to a jQuery object. You can
pass a string as an optional second argument to either, and that string will be *added to*
the jQuery object's classes.

    peg "*foo*", "color-clock"

If you pass a function as the second argument to `put` or `peg`, instead of a string, then
the jQuery object is passed to your function, which should return a jQuery object that will
be appended.

    peg "*hello world*", (e) -> e.css color: "hotpink"

## Magic or More Magic

The `put` and `peg` functions both apply a little magic to help make them easier to use
interactively. They internally add a class named `unspaced` to the output object so it
is appended directly to the bottom of the board [without whitespace]. Both functions also
return `undefined`, so they look clean when they're called.

Sometimes, and often in scripts, this magic becomes a bit counter-intuitive and annoying.
Both `put` and `peg` have low-magic versions of themselves, named `put.low` and `peg.low`.
The low-magic versions do not make the output `unspaced`, so they appear after a newline,
and they return the jQuery object they append.

    peg.low "Some `code` example."
    .css color: "sienna"

## Function: `clear`

The `clear` function clears the board. This destroys anything that was on there.

## Function: `print`

The `print` function takes a file hash, or a key for one, or a URL string. If the
string is a URL, it's loaded and the content is rendered as Markdown. If the argument
resolves to a file chit, the chit's content is rendered.

URLs are distinguished from key strings by simply checking if the string contains a slash;
if it does, it's a URL, else a key string.

This line renders the next page in the book.

    print "/docs/storage.md"
