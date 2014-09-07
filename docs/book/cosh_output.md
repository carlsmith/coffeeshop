# Output Functions

The are six output functions. Four append stuff to the board; one clears it.

- `put` Appends a pretty printed evaluation of any expression to the board.
- `peg` Appends a string of Markdown, a DOM node or a jQuery object to the board.
- `append` Works like `peg`, but is more generic, for use in scripts.
- `show` Appends Markdown to the board from a chit or a remote resource.
- `load` Loads and renders a CoffeeScript or Markdown file from a URL.
- `clear` Clears the board.

## Function: `put`

The `put` function takes a single argument, any object, and pretty prints it.
Strings are printed in green; everything else is cyan.

    put key for key of localStorage
    2 ** 8

When you enter code in the shell, the last value to be evaluated is put
automatically, so you don't need to call `put` yourself.

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

The first argument is internally normalised to a jQuery object. If you pass a
function as the second argument, the jQuery object is passed to your function,
which must return a jQuery object, which will then be appended.

    peg "*hello world*", (element) -> element.css color: "hotpink"

You can pass a string as the second argument, instead of a function, and the
string is simply added to any CSS classes the rendered object has.

## Function: `append`

The `append` function works just like the `peg` function, but is less magical.
The `put` and `peg` functions use `append` internally, and add a class named
`unspaced` to the output, which makes the output append directly below the input.
This magic's helpful when you're hacking interactively ~ you never even think
about it ~ but can be confusing in a script.

The `append` function also returns the jQuery object it appends, where `put` and
`peg` return `undefined`, and only the thing that was put or pegged is rendered.

    $foo = append "This *Markdown* is converted to the following jQuery object:"
    .css color: "tomato"

You can silence `append` in the shell by referencing a non-existant property last.

    append "foo"
    .addClass "unspaced"
    .shush

## Function: `load`

The `load` function takes one required argument, a URL string. It loads the remote
resource and returns it. You can pass a callback as the second argument, and `load`
will operate asynchronously instead, returning `undefined` immediately.

## Function: `clear`

The `clear` function clears the board. This destroys anything that was on there.

## Function: `view`

The `view` function takes a file hash, or a key for one, or a URL string. If the
string is a URL, it's loaded and the content is rendered as Markdown. If the argument
resolves to a file chit, the chit's content is rendered.

URLs are distinguished from key strings by simply checking if the string contains a
colon or a slash; if it does, it's a URL, else a key string.

This line renders the next page in the book.

    view "/docs/book/cosh_storage.md"
