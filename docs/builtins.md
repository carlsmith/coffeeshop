# Builtins

To be a nice programming environment, the browser needs some extras.
CoffeeShop bundles some.

## Main Libraries

CoffeeShop takes some liberties with the global namespace. [This article][1]
from the SugarJS developers helps explain how. The [SugarJS][2] library has
been applied wholesale, extending the builtin types with a large collection
of methods.

    [].equals []

As ever, [jQuery][3] is available globally as `jQuery` and `$`.

## Shell Functions

Cosh adds a collection of functions that allow for shell style programming.
For example, the following code clones a gist, sets it to local storage, then
opens it in the editor.

    edit set clone "98f97a41924ca81c9863"

[Output Functions](/docs/output.md)

These functions are used to render things to the board, and to clear it.

- `put` Append a pretty printed evaluation of any expression to the board
- `peg` Append Markdown, a DOM node or a jQuery object to the board
- `print` Print a resource to the board as Markdown
- `clear` Clear the board

[Storage Functions](/docs/storage.md)

These functions are used to store and retrieve JSON serialisable values from
local storage.

- `set` Set a value to local storage, then return it
- `get` Get a value from local storage, then return it
- `pop` Pop a value from local storage, then return it

[Chit Functions](/docs/chits.md)

These functions are used to manage *chits*. Chits are basically just JSON
serialisable hashes and are explained properly later. They serve the same
purpose as files and gists.

- `run` Run a chit
- `edit` Open a chit in the editor
- `chit` Create a new chit, then return it
- `clone` Create a new chit from a gist ID
- `publish` Publish a chit as a gist
- `push` Update a published gist from a chit

## Shell Components

The slate and editor are both instances of Ace, so you can use all the Ace
methods. A couple of extras have been added.

- `slate` The slate ACE instance:
    - `slate.reset` Reset the input history
    - `slate.push`  Push a string to the slate
- `editor` The editor ACE instance:
    - `editor.set` Set the current chit to local storage
    - `editor.run` Run the highlighted code or all the code
    - `editor.print` Print the highlighted code or all the code

## Loose Ends

Note that anything not defined in this document may change without notice.

- `coffee` The CoffeeScript Compiler.
- `gallery` Function: Takes a gist ID and opens the gist in the Gallery
- `galleryMode` Bool: `true` if the app is in Gallery Mode, else `false`
- `uniquePIN` Function: No args, returns an incremented integer per call
- `uniqueID` Function: No args, returns `"coshID#{ do uniquePIN }"`

[1]: http://sugarjs.com/native
[2]: http://sugarjs.com
[3]: http://jquery.com
