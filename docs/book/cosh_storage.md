# Storage Functions

There are three storage functions, wrapping `localStorage` with JSON and a tiny
bit of magic. You should use these three functions for all local persistency.

- `set` Sets a JSON value, which cloud be a hash, to localStorage, then returns it.
- `get` Gets a JSON value from localStorage , then returns it.
- `pop` Removes a JSON value from localStorage, then returns it.

## Function: `set`

The `set` function sets objects to storage ~ it saves them. In the simplest
case, it takes two arguments, a key string and a JSON value.

    set "someKey", [0, 1, 2]

You can also pass in a hash as the only argument. Hashes and introduced in [the
next page][1].

The `set` function returns the value it set to storage.

Note: Throughout cosh's API, URLs are distinguished from key strings by simply checking
if the string contains a slash (`/`). If it does, it's a URL, else a key. For this reason,
you can not create keys containing a slash [except by hacking on `localStorage` directly].

Keys of the pattern `cosh*` are reserved.

## Function: `get`

The `get` function takes a single argument, always a key string, and returns the
value stored with that key, or `null` if it doesn't exist.

    get "someKey"

## Function: `pop`

The `pop` function takes a single argument, either a key string or a hash,
deletes the object from storage, then returns the value or `null` if it
doesn't exist.

    pop "someKey"

Next Page: [Chits][1]

[1]: /docs/book/cosh_chits.md
