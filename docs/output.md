# Output Functions

The are four output functions. Three append stuff to the board; one clears it.

- `put` Appends a pretty printed evaluation of any expression to the board.
- `peg` Appends a string of Markdown, a DOM node or a jQuery object to the board.
- `print` Loads and appends a resource to the board.
- `clear` Clears the board.

## Introducing the `put` Function

The `put` function takes a single argument, any object, and pretty prints it. Strings are
printed in green; everything else is pink.

    put key for key of localStorage

When you enter code in the shell, the last value to be evaluated is put automatically.

## Introducing the `peg` Function

The `peg` Function appends DOM stuff to the board. It accepts Markdown strings.

    peg """
        # A Markdown Page

        - with bullet points and *emphasised text*
        - some **bold text** and some `inline code`
        """

In Markdown, anything within HTML tags is ignored by the compiler. Markdown is a strict
superset of HTML, so you can have canvases, web components or anything else in Markdown.
You can put script and style tags in Markdown too, but there are cleaner ways to achieve
the same thing.

The `peg` function also accepts DOM nodes and jQuery objects.

    peg $("<img>").attr height: 256, src: "/images/logo.png"

Note that you can also pass `null` or `undefined` as the first argument, and it'll default
to an empty div.

## Tweaking `put` and `peg` calls.

The first argument to `put` and `peg` is internally normalised to a jQuery object. Whatever
type of object you pass in as the first argument, the function will convert it to a jQuery
object and append it to the board. You can tweak the function to modify the jQuery object
in a number of ways, using the optional second argument.

If the second argument to either `put` or `peg` is a string, it will be *added to* the
jQuery object's classes. The string can contain multiple class names, separated by spaces.

    peg "*hello emphasis*", "color-operator"

If the second argument to either `put` or `peg` is a function, then the jQuery object that
the first argument is converted to is passed to your function, which should return a jQuery
object that will be appended.

    peg "looking hot", (e) -> e.css color: "hotpink"

If the second argument to either `put` or `peg` is a hash, the hash will be checked for
three properties, `id`, `class` and `func`. The `class` and `func` properties work as the
string and function options above. The `id` option sets the jQuery object's ID. There are
examples in the next section.

## Magic or More Magic

The `put` and `peg` functions both apply a little magic to help make them easier to use
interactively. They internally add a class named `unspaced` to the output object so it
is appended directly to the bottom of the board [without whitespace]. Both functions also
return `undefined`, so they look clean when they're called interactively.

Sometimes, and often in scripts, this magic becomes a bit counter-intuitive and annoying.
Both `put` and `peg` have low-magic versions of themselves, named `put.low` and `peg.low`.
The low-magic versions do not make the output `unspaced`, so they appear after a newline.
They also return the jQuery object they append.

    peg.low "Some `code` example."
        .css color: "sienna"

To make the low-magic versions append their outputs unspaced, just add the class yourself.

    peg.low "foo", "unspaced"

You can use the low-magic versions interactively to get a look at what you're actually
appending.

    peg.low "foo",
        id: "bar"
        class: "unspaced"
        func: (e) -> e.css textDecoration: "underline"

## Function: `clear`

The `clear` function clears the board. This destroys anything that was on there.

## Function: `print`

The `print` function takes a file hash, or a key for one, or a URL string. If the string
is a URL, it's loaded and the content is rendered as Markdown. If the argument resolves
to a file chit, the chit's content is rendered.

URLs are distinguished from key strings by simply checking if the string contains a slash;
if it does, it's a URL, else a key string.

This line renders the next page in the book.

    print "/docs/storage.md"
