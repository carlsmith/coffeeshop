# CoffeeShop

CoffeeShop's a novel, HTML5 shell. It has a familiar interface, a command line and editor,
but instead of just spitting out strings, you can interact with anything your browser can
render.

CoffeeShop uses GitHub Gist to let you share stuff, and there's a hosted version of the
shell running in 'gallery mode' ~ so it has no persistency. You can use it to share your
gists as little web apps, a bit like JSFiddle, but more romantic.

You can also clone a gist and use it in your own shell, but you need to trust it as it'll
then have access to your own shells internals.

## Why CoffeeScript

CoffeeScript is a modern, highly expressive language that compiles to JavaScript, but
doesn't try to replace JavaScript; it's the zen of JavaScript. Nothing from CoffeeScript
exists at runtime; it's a direct translation. You use the same libraries and APIs and it's
the same runtime. The only difference is that you now have a much more elegant language to
express yourself with.

For hacking a browser, the best language you can use is the subset of JavaScript that
CoffeeScript sugars, but the syntax of JavaScript doesn't fit the programming style.
CoffeeScript was literally made for it.

CoffeeScript syntax is also pretty much ideal for interactive programming. Having light
syntax with optional delimiters and significant whitespace, and where everything's an
expression, is extra helpful in a shell.

---

[Return to the Front Page](/docs/front.md)

[1]: https://github.com/carlsmith/coffeeshop/issues
