# Introducing Hashes

In CoffeeShop, hashes are used everywhere. They're defined more specifically
than what is normally meant by the term 'hash'. We just say hash, because it's
short and sounds cool. A cosh style hash is a JSON object with at least one
key, named `coshKey`, that has a string value that acts like a filename.

If you set a hash, you pass it to `set` as the only argument. Set will use the
`coshKey` value as the key, and the entire hash as the value.

    basicHash = coshKey: "foo"
    set basicHash

You coud then remove the hash from storage with `nuke "foo"` [or
`nuke basicHash` where `basicHash.coshKey is "foo"` ].

Setting a hash with an explicit key will overwrite the hash's cosh key.

    set "bar", basicHash # sets basicHash, but with the cosh key "bar"

Hashes have no real schema beyond needing a `coshKey` string property and
being JSON serialisable. However, most hashes in practice also have two other
properties, named `description` and `content`. These hashes are what cosh uses
instead of files. The cosh key is the filename and the content is the file's
body. The description is useful in the shell's hash editor, where it appears
next to the key, and when publishing a hash as a Gist. The description should
be short, and ideally, descriptive. A common hash might look like this:

    {
     "coshKey": "foo.coffee"
     "description": "Let foo be true.",
     "content": "foo = true",
    }

## Function `edit`

You can open a file hash in the editor by passing the hash to the `edit`
function. This does not set the hash to storage, but you can pass the hash to
`set`, and pass the returned hash to `edit`, doing something like
`edit set someHash`.

Note that `edit` can also take a key string, and will open the hash from
storage, if it exists ~ `edit "foo.coffee"`.

## Function: `hash`

The `hash` function is used to create hashes with a cosh key, description
and content. It can be called in a number of ways. The first argument is always
required and must be a key string. The hash returned in that case will have
that key and empty strings for its content and description.

The second arg, if it's provided and it's a string, sets the description.

An optional last argument, which will always be second or third, should be a
hash. If provided, this hash will be used to build the new hash from.

    hash "foo.coffee", "Let foo be true." # has empty content string
    hash "foo.coffee", content: "foo = true" # has empty description

The return value can be set and edited.

    edit set hash "foo.coffee",
        description: "Let foo be true."
        content: "foo = true"

You can do stuff like `edit hash "foo.coffee"` to open a new empty file named
`foo.coffee`.

## Function: `run`

The `run` function takes a single argument, a hash with a `content` property,
or a key string for such a hash in storage. It executes the hash's content.

    run "foo.coffee"

Next Page: [Hashes as Gists](/docs/book/cosh_gists.md)
