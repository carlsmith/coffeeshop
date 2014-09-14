# Introducing Chits

In CoffeeShop, chits are used everywhere. A chit is a JSON serialisable hash, so the
most simple chit would be `{}`. This criterion is the only one that all chits will
meet. Chits usually meet more criteria too.

The purpose of chits is to allow data structures to be passed around easily, while
ensuring that certain assumptions about the data are safe. You don't normally need to
deal with chits very directly, as you'll just think of them as files, gists or whatever
kind of data they represent. That said, it's useful to quickly breeze over what they are,
so you don't find the functions that work with them too magical.

## Abstract

A chit is **always** a JSON serialisable hash. Chits are normally further defined by
secondary criteria in a strict hierarchy...

Chits have *kinds*, with the most simple kind being `chit` itself. To define a new
kind of chit, you define criteria it must meet. This is not done in code, you just
define some criteria externally.

All new kinds of chit are derived from one or more other kinds of chit, possibly just
`chit`. The new kind must meet *every* criteria of *every one* of the kinds that it
extends. It can not redefine something it inherits; this is what's meant here by a
*strict* hierarchy.

A new kind of chit may use any new criteria.

Any object that meets all the criteria for a given kind is of that kind, and can be
used wherever that kind can be used. Chits are duck typed data structures.

## Classroom Example

Any hierarchy of chits starts with `chit`, defined as a JSON serialisable hash.

You could define a 'key chit' by stating the following criteria:

- A key chit is a chit.
- A key chit always has a property named `key`.
- The `key` property must be a single-line string.

You could then define new kinds of chit that extend the key kind. For example you
could define a 'file chit':

- A file chit is a key chit.
- A file chit always has a property named `body`.
- The `body` property must be a string.

Now a function can be defined that accepts any key chit, and it would just work on
a file chit too.

You could go on to define a 'gist chit' that extends the file kind, that could then
be used anywhere you can use a chit, a key chit, a file chit or a gist chit.

To learn how chits are used in cosh, see the [Chits as Files](/docs/files.md) page.
