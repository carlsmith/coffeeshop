# Chits

In CoffeeShop, chits are used everywhere. A chit is a JSON serialisable hash,
with at least one property `coshKey`. The value of `coshKey`, a string, must
be a valid key in local storage. A simple chit might look like...

    coshKey: "foo"

The purpose of chits is to allow data structures to be passed around easily,
while ensuring that certain assumptions about the data are safe. You do not
normally need to think about chits directly, as you will just think of them
as files, gists or whatever kind of data they represent. That said, it is a
good idea to quickly go over how they are used, so you do not find functions
that work with them too magical.

## Chit Basics

To store a chit, you can just pass it to `set` as the only argument. The
function will use the `coshKey` value as the key, and the entire chit as
the value to set.

    foo = coshKey: "foo"
    set foo

You could remove the above chit from local storage with `pop "foo"` or
`pop foo`, as `pop` can take a key or chit argument too.

Setting a key chit to storage with an explicit key argument will overwrite
the chit's `coshKey` property. The following code sets `foo.coshKey` to
`"bar"`, then sets `foo` to local storage.

    set "bar", foo

## Files

CoffeeShop uses chits for files. File chits have two extra properties,
named `description` and `content`. Both must be strings.

The `coshKey` property that all chits have is used as the filename. The
`content` property is used as the body of the file. The `description`
property is displayed in the editor, and is used as the gist description
on GitHub if the file is ever published.

The description should be short, on one line, and ideally, descriptive.
A simple file chit might look like this:

    coshKey: "foo.coffee"
    description: "Let foo be true."
    content: "foo = true"

## The Config File

The configuration file, `config.coffee`, is an example of a file chit. It is
loaded into the editor whenever the shell is launched, and is also executed
automatically. You can override the automatic execution by using the safemode
launch code.

    https://shell-cosh.appspot.com#safemode

## Function `edit`

You can open a file chit in the editor by passing it to the `edit` function.
This does not set the chit to storage, but you can pass the chit to `set`,
and pass the returned chit to `edit` if you like.

    edit set
        coshKey: "foo.coffee"
        description: "Let foo be true."
        content: "foo = true"

Note that `edit` can also take a key string, and will open the file chit from
storage, assuming the key exists.

    edit "foo.coffee"

## Function: `chit`

The `chit` function is used to create file chits.

The first argument is always required and is the key. The second arg sets the
`description` property and defaults to an empty string. The third arg sets the
`content` property and defaults to an empty string too.

    chit "pacman.coffee", "A PAC-MAN Clone"

The return value is always the newly created chit. The following code
evaluates to the same object as the last example.

    coshKey: "pacman.coffee"
    description: "A PAC-MAN Clone"
    content: ""

## Function: `run`

The `run` function takes a file chit, or a key for one, or a URL string.
If the string is a URL, it is loaded, and the content is executed. If the
argument resolves to a file chit, the chit's content is executed.

    run "foo.coffee"

The `run` function supports Literate CoffeeScript automatically if the chit's
key or the resource's path ends with `.coffee.md` or `.litcoffee`.

Note: URLs are distinct from storage keys as URLs must contain a slash.

Next Page: [Gists](/docs/gists.md)
