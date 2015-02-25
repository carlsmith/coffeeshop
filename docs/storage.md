# Storage Functions

These functions are used to store and retrieve JSON serialisable values from
local storage.

- `set` Set a value to local storage, then return it
- `get` Get a value from local storage, then return it
- `pop` Pop a value from local storage, then return it

## Function: `set`

The `set` function sets objects to storage - it saves them. In the simplest
case, it takes two arguments, a key string and a JSON value.

    set "someKey", [0, 1, 2]

You can also pass a chit as the only argument. Chits are introduced on
[the next page][1].

The `set` function returns the value it sets to storage.

## Function: `get`

The `get` function takes a single argument, a key string, and returns the
value stored with that key, or `null` if it does not exist.

    get "someKey"

## Function: `pop`

The `pop` function takes a key, and deletes the value from storage, then
returns it. The function returns `null` if the key did not exist.

    pop "someKey"

## Valid Key Values

In CoffeeShop, local storage keys can not contain any of these characters:

    " + - * / : ( ) { } @ $

Keys starting with `cosh` are also reserved.

Next Page: [Chits][1]

[1]: /docs/chits.md
