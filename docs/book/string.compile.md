# The `String::compile` Method

Strings have a method named `compile` which wraps the CoffeeScript and Marked
compilers, allowing you to compile strings of CoffeeScript and Markdown, to
JavaScript and HTML respectively. Other compilers may be added.

The `compile` method takes one required argument, a string that names the
compiler to use. For ease of use, each compiler name has aliases and none
of the names are case sensitive. Use `"cs"`, `"coffee"` or `"coffeescript"`
for CoffeeScript, and `"md"` or `"markdown"` for Markdown.

    "# Hello World".compile "md"

If you pass more than one argument, all extra arguments are passed to the
chosen compiler after the string the method is called on. In practice, this
just means you can pass compiler options in as the second argument.

    "square = (x) -> x * x".compile "cs", bare: true

Use `string.compile "cs", literate: true` to compile [Literate CoffeeScript][1]
strings.

[1]: http://coffeescript.org/#literate
