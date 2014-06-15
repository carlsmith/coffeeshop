# Hashes as Gists

Hashes used as files will have at least three properties, named `coshKey`,
`description` and `content`. These properties map to [gists][1], where the
cosh key is the gist's filename.

There are three functions for managing gists.

- `clone` Creates a hash populated from a GitHub Gist.
- `publish` Publishes a hash as a Gist on GitHub.
- `push` Updates a published Gist from a hash.

## Function: `clone`

The `clone` function works a lot like `hash`, but simply accepts a Gist ID as
a string, then returns a hash populated with data from the gist. Because it
returns a hash, it can be piped with calls to `set`, `edit` and `run`.

    set clone "98f97a41924ca81c9863"

Note that a cloned hash includes three extra keys, named `gistId`, `owner` and
`galleryURL`.

    {
     "coshKey": "foo.coffee",
     "description": "Let foo be true.",
     "content": "foo = true",
     "gistId": "98f97a41924ca81c9863",
     "owner": "johnDoe",
     "galleryURL": "https://gallery-cosh.appspot.com/#98f97a41924ca81c9863"
    }

## Function: `publish`

The `publish` function takes a file hash or gist hash, or a key string for
either, and publishes the hash as a gist on GitHub.

The `publish` function returns a hash, equal to what `clone` would return for
the newly published gist, which can be piped. The following line would first
publish `foo.coffee`, then overwrite it in storage with the gist data.

    set publish "foo.coffee"

You could rename the gist with:

    set "bar.coffee", publish "foo.coffee"

Note that you must set the gist hash returned to local storage if you want to
`push` that hash later. If you forget, clone your published gist.

## Function: `push`

The `push` function takes a gist hash, or a keystring for one, and uses it to
update the published version on GitHub Gist. The hash must have a `gistId`
for a published gist that belongs to you.

It returns the gist as a hash, etc.

## Authorisation

You need a GitHub account to publish gists through cosh and to push to them.
Use the auth link in the banner to manage log in.

Next Page: [Publishing](/docs/book/cosh_publishing.md)

[1]: https://gist.github.com
