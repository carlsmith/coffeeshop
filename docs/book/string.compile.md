# The `String::compile` Method

Strings have a method named `compile` which wraps the CoffeeScript and Marked
compilers, allowing you to compile strings of CoffeeScript and Markdown, to
JavaScript and HTML respectively. Other compilers may be added.

The `compile` method takes one required argument, a string that names the compiler
to use. Each compiler name is aliased and none of the names are case sensitive.
Use `cs`, `coffee` or `coffeescript` for CoffeeScript, and `md` or `markdown`
for Markdown.

    "# Hello World".compile "md"

If you pass a second argument, it should be an options hash, which is passed to
the chosen compiler.

    "square = (x) -> x * x".compile "cs", bare: false

Note that in cosh, the default CoffeeScript compiler option for `bare` is `true`.
If it is set to `false`, the compiled JavaScript will be wrapped in an anonymous,
self-invoking function.

Set the CoffeeScript compiler option `literate` to `true` to compile strings as
[Literate CoffeeScript][1].

[1]: http://coffeescript.org/#literate
