# Output Functions

These functions are used to render things to the board, and to clear it.

- `put` Append a pretty printed evaluation of any expression to the board
- `peg` Append Markdown, a DOM node or a jQuery object to the board
- `print` Print a resource to the board as Markdown
- `clear` Clear the board

## Introducing the `put` Function

The `put` function takes a single argument, any type, and pretty prints it.
Strings are printed in green; everything else is pink.

    put key for key of localStorage

When you enter code in the shell, the last value to be evaluated is put
automatically.

## Introducing the `peg` Function

The `peg` function appends Markdown to the board.

    peg """
        # A Markdown Page

        - with bullet points and *emphasised text*
        - some **bold text** and some `inline code`
        """

The `peg` function also accepts DOM nodes and jQuery objects.

    peg $("<img>").attr height: 256, src: "/images/logo.png"

Note that you can also pass `null` or `undefined` as the first argument,
and it will be treated as an empty `div`. That can be useful...

## Tweaking `put` and `peg` Calls

The first argument to `put` or `peg` is internally normalised to a jQuery
object. Whatever type of object you pass in as the first argument, it will be
converted to a jQuery object and appended to the board. You can tweak the
function to modify that jQuery object in a number of ways, using the
optional second argument.

If the second argument to either `put` or `peg` is a string, it will be
*added to* the jQuery object's classes. The string can contain multiple
class names, separated by spaces.

    peg "*hello emphasis*", "color-operator"

If the second argument to either `put` or `peg` is a function, then the jQuery
object is passed to the function, which should return a jQuery object that will
be appended instead.

    peg "looking hot", (e) -> e.css color: "hotpink"

If the second argument to either `put` or `peg` is a hash, the hash will be
checked for three properties, named `id`, `class` and `func`. The `class` and
`func` values work the same way as passing the string and function arguments
described above. The `id` option sets the jQuery object's ID.

## Magic or More Magic

The `put` and `peg` functions both apply a little magic to help make them
easier to use interactively. They internally add a class named `unspaced` to
the output so it is appended directly to the bottom of the board, without any
whitespace. Both functions also return `undefined`, so they look clean when
they are called interactively.

In scripts, this magic becomes a bit annoying. Both `put` and `peg` have a
low-magic version of themselves, named `put.low` and `peg.low`. The low-magic
versions do not make the output `unspaced`, so they appear after a newline.
They also return the jQuery object they append.

    peg.low "Some `code` example."
        .css color: "sienna"

To make the low-magic versions append their outputs unspaced, just add the
class yourself.

    peg.low "foo", "unspaced"

You can use the low-magic versions interactively to get a look at what you
are actually appending.

    peg.low "foo",
        id: "bar"
        class: "unspaced"
        func: (e) -> e.css textDecoration: "underline"

## Function: `clear`

The `clear` function clears the board. It destroys everything on there. It
also returns the board as a jQuery object. Just use <kbd>Meta.Esc</kbd> in
the shell or editor.

## Function: `print`

The `print` function takes a file hash, or a key for one, or a URL string.
If the string is a URL, the resource is loaded and the content is rendered
as Markdown. If the argument is a chit or key for one, the chit's content
is rendered.

URLs are distinguished from key strings by simply checking if the string
contains a slash; if it does, it is a URL, else it is a key string.

This line renders the next page in this book.

    print "/docs/storage.md"
