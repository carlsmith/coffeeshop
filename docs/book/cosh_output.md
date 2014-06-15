# Output Functions

The are five output functions. Four append stuff to the board; one clears it.

- `put` Appends a pretty printed evaluation of any expression to the board.
- `peg` Appends a string of Markdown, a DOM node or a jQuery object to the board.
- `append` Works like `peg`, but is more generic, for use in scripts.
- `load` Loads and renders a CoffeeScript or Markdown file from a URL.
- `clear` Clears the board.

## Function: `put`

The `put` function takes a single argument, any object, and pretty prints it.
Strings are printed in green; everything else is cyan.

When you enter code in the shell, the last value to be evaluated is put
automatically, so you don't need to call `put` yourself.

    put key for key of localStorage
    2 ** 8

## Function: `peg`

The `peg` Function appends DOM stuff to the board. It accepts Markdown
strings, which can include HTML.

    peg """
    # A Markdown Page

    - with bullet points and *emphasised text*
    - some **bold text** and some `inline code`
    """

The `peg` function also accepts DOM nodes and jQuery objects.

    peg $("<img>").attr height: 256, src: "/images/logo.png"

You can pass in an optional second argument, which must be a string or
function. If the argument is a string, it's *added to* any CSS classes the
rendered object has.

The first argument is internally normalised to a jQuery object. If you pass a
function as the second argument, the jQuery object is passed to your function,
which must return a jQuery object, which will then be appended.

    peg "hello world", (node) -> node.css color: "hotpink"

## Function: `append`

The `append` function works just like the `peg` function, but is less magical.
The `put` and `peg` functions use `append` internally, and add a class named
chit to the output, which makes the output append directly beneath the input.
This magic is helpful when you're hacking inter-actively, and you never need to
think about it, but can be confusing in a script. Just use `put` and `peg`
interactively, and use `append` in scripts.

The `append` function also returns the jQuery object it appends.

    $foo = append "Here is a jQuery object..."
    .css color: "hotpink"

## Function: `load`

The `load` function takes a single argument, a URL string. If the string
matches the pattern `*.coffee`, it's rendered as CoffeeScript, and *everything*
else is rendered as Markdown. Filenames matching the patterns `*.md` and
`*.markdown` will always be rendered as Markdown.

This line renders the next page in the book.

    load "/docs/book/cosh_storage.md"

## Function: `clear`

The `clear` function clears the board. This destroys anything that was on there.
