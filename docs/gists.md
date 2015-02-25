# Chits as Gists

There are three functions for managing gists.

- `clone` Create a new chit from a gist ID
- `publish` Publish a chit as a gist
- `push` Update a published gist from a chit

File chits always have at least three string properties, named `coshKey`,
`description` and `content`. These properties map to [gists][1], where the
cosh key is used as the gist's filename.

Gist chits extend the file chits by adding three extra string properties,
named `gistID`, `owner` and `galleryURL`. An example gist chit:

    coshKey: "foo.coffee"
    description: "Let foo be true."
    content: "foo = true"
    gistID: "98f97a41924ca81c9863"
    owner: "johnDoe"
    galleryURL: "https://gallery-cosh.appspot.com/#98f97a41924ca81c9863"

## Function: `clone`

The `clone` function simply accepts a Gist ID as a string, and returns a gist
chit populated with data from GitHub.

    clone "98f97a41924ca81c9863"

## Function: `publish`

The `publish` function takes a file chit, or a key string for one, then
publishes the chit as a gist on GitHub. The function returns a gist chit,
equal to what `clone` would return, for the newly published gist. It also
updates the file chit to make it a gist chit in local storage.

    publish "foo.coffee"

## Function: `push`

The `push` function takes a gist chit, or a keystring for one, and uses it to
update the published version on GitHub. The published gist must belong to you.
The function returns the gist chit.

    push "foo.coffee"

## Authorisation

You need a GitHub account to publish gists through cosh and to push to them.
Use the auth link in the banner to manage log in.

Next Page: [Publishing](/docs/publishing.md)

[1]: https://gist.github.com
