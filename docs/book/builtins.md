# Builtins

CoffeeScript is a really nice language, but languages needs libraries and stuff.
CoffeeShop bundles some. This page offers a quick overview of everything you
have; other docs explain how it all works.

## Extended Types

CoffeeShop takes some liberties with the global namespace. [This article][1]
from the SugarJS developers helps explain why, though cosh goes a bit further.
Enjoying the language and having fun is better than living in fear of things
that'll probably never happen, and wont really matter to us even if they do.

The entire [Sugar.js][2] library has been applied to *all objects*. Sugar gives
all CoffeeScript types a large collection of methods, and your own classes
inherit from them.

    [].equals []

Strings also have a [`compile`](/docs/book/string.compile.md) method you can
use to compile strings of CoffeeScript and Markdown.

As ever, [jQuery][3] is available globally as `jQuery` and `$`, and [toastr][4]
is also available as `toastr`.

## Shell Functions

Cosh adds a collection of functions that take advantage of CoffeeScript's
optional brackets to allow for shell style, interactive programming. The
following code clones a gist, sets it to local storage using its Gist file
name, then opens it in the editor.

    edit set clone "98f97a41924ca81c9863"

The shell functions are listed below. chits are basically hashes and are
explained properly later. For now, just think of them as files.

[Output Functions](/docs/book/cosh_output.md)

- `put` Appends a pretty printed evaluation of any expression to the board.
- `peg` Appends a string of Markdown, a DOM node or a jQuery object to the board.
- `print` Loads a local or remote resource and prints it.
- `clear` Clears the board.

[Storage Functions](/docs/book/cosh_storage.md)

- `set` Sets a value to localStorage, then returns it.
- `get` Gets a value from localStorage , then returns it.
- `pop` Removes a value from localStorage, then returns it.

[Chit Functions](/docs/book/cosh_chits.md)

- `chit` Creates a chit from its arguments.
- `edit` Open a chit in the editor.
- `run` Runs a chit or remote resource as a shell script.
- `clone` Creates a chit populated from a GitHub Gist.
- `publish` Publishes a chit as a Gist on GitHub.
- `push` Updates a published Gist from a chit.

## Shell Components

The slate and editor are both instances of Ace, so you can use all of Ace's
methods. A couple of extras have been added.

- `slate` The slate's ACE instance.
    - `slate.reset` Resets the input history.
    - `slate.push`  Pushes a string to the slate.
- `editor` The chit editor's ACE instance.
    - `editor.set` Set the current chit to storage.
    - `editor.run` Run the highlighted code or all the code.
    - `editor.print` Print the highlighted code or all the code.

## Builtin Libraries

- `ace` Ace text editor.
- `jQuery` & `$` jQuery awesome.
- `toastr` Toastr notifications.
- `require` Module loader [don't use yet, needs work].

## Loose Ends

- `galleryMode` True if the app is in gallery mode, else false.
- `cosh` App internals.

[1]: http://sugarjs.com/native
[2]: http://sugarjs.com/
[3]: http://jquery.com/
[4]: https://github.com/CodeSeven/toastr
