# Chits as Files

Cosh defines an elementary kind of chit, a 'key chit'. In cosh, key chits always have at
least one property, a string named `coshKey`, which is a valid key in local storage.

To store a key chit, you can just pass it to `set` as the only argument. Set will use
the `coshKey` value as the key, and the entire chit as the value.

    keyChit = coshKey: "foo"
    set keyChit

You coud then remove the chit from storage with `pop "foo"` or `pop keyChit`,
as `pop` can take a key chit argument too.

Setting a key chit with an explicit key argument will overwrite the chit's `coshKey`
property.

    set "bar", keyChit # sets keyChit.coshKey to "bar", then sets keyChit

## File Chits

File chits extend key chits with two more required properties, named `description` and
`content`; both must be strings. These chits are what cosh uses instead of files. The
inherited `coshKey` property is used as the filename, and the `content` property is used
as the file's body. The `description` property is useful in the shell's chit editor, where
it appears next to the key, and when publishing a chit as a Gist. The description should
be short, on one line and, ideally, descriptive. A common file chit might look like this:

    {
     "coshKey": "foo.coffee"
     "description": "Let foo be true.",
     "content": "foo = true",
    }

The configuration file, `config.coffee`, is an example of a file chit.

## Function `edit`

You can open a file chit in the editor by passing the chit to the `edit` function.
This does not set the chit to storage, but you can pass the chit to `set`, and pass
the returned chit to `edit`.

    edit set
        coshKey: "foo.coffee"
        description: "Let foo be true.",
        content: "foo = true"

Note that `edit` can also take a key string, and will open a file chit from storage,
assuming the key exists.

    edit "foo.coffee"

## Function: `chit`

The `chit` function is used to create chits, mostly file chits. It can be called in a
number of ways. The first argument is always required and must be the chit's cosh key.
If you only pass that first argument, the chit returned will have that key and empty
strings for its `content` and `description` properties.

The second arg, if it's provided and it's a string, sets the `description` property.

An optional last argument, which will always be second or third, should be a chit.
If provided, this chit will be used to build the new chit from.

    chit "foo.coffee", "Let foo be true." # has empty content string
    chit "foo.coffee", content: "foo = true" # has empty description

The return value is the newly created chit.

    edit set chit "foo.coffee", "Let foo be true.", content: "foo = true"

You can do stuff like `edit chit "foo.coffee"` to open a new empty file named
`foo.coffee`.

## Function: `run`

The `run` function takes a file chit, or a key for one, or a URL string. If the
string is a URL, it's loaded and the content is executed. If the argument resolves to a
file chit, the chit's content is executed.

    run "foo.coffee"

The `run` function supports Literate CoffeeScript automatically if the chit's key or the
resource's path ends with `.coffee.md` or `.litcoffee`.

Note: Key strings are distinguished from URL strings by checking if the string contains a
slash (`/`). If it does, it's a URL, else a key. The `set` function enforces this.

Next Page: [Chits as Gists](/docs/gists.md)
