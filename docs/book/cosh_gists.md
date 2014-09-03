# Chits as Gists

There are three functions for managing gists.

- `clone` Creates a gist chit populated from a GitHub Gist.
- `publish` Publishes a file chit as a Gist on GitHub.
- `push` Updates a published Gist from a gist chit.

File chits always have at least three string properties, named `coshKey`, `description`
and `content`. These properties map to [gists][1], where the cosh key is used the gist's
filename. Gist chits extend the file kind, adding three extra, required string properties,
named `gistId`, `owner` and `galleryURL`. An example gist chit:

    {
     "coshKey": "foo.coffee",
     "description": "Let foo be true.",
     "content": "foo = true",
     "gistId": "98f97a41924ca81c9863",
     "owner": "johnDoe",
     "galleryURL": "https://gallery-cosh.appspot.com/#98f97a41924ca81c9863"
    }

## Function: `clone`

The `clone` function works like `chit`, but simply accepts a Gist ID as a string.
It returns a gist chit populated with data from GitHub.

    run clone "98f97a41924ca81c9863"

## Function: `publish`

The `publish` function takes a file chit, or a key string for one, and publishes
the chit as a gist on GitHub.

The `publish` function returns a gist chit, equal to what `clone` would return for
the newly published gist. The following line would first publish `foo.coffee`, then
overwrite it in storage with the gist chit that `publish` returns.

    set publish "foo.coffee"

You could rename the gist with:

    set "bar.coffee", publish "foo.coffee"

Note that you must set the chit returned to local storage if you want to `push` to that
gist later. If you forget, just clone your published gist.

## Function: `push`

The `push` function takes a gist chit, or a keystring for one, and uses it to update the
published version on GitHub Gist. The published gist must belong to you too. It returns
the gist chit.

## Authorisation

You need a GitHub account to publish gists through cosh and to push to them.
Use the auth link in the banner to manage log in.

Next Page: [Publishing](/docs/book/cosh_publishing.md)

[1]: https://gist.github.com
