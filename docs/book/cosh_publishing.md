# Publishing

Once a chit is published as a Gist, you or anyone else can run the script in
a shell, as easy as `run clone "98f97a41924ca81c9863"`. Doing this **can
be dangerous**. You are trusting the person who wrote the code not to do bad
stuff.

## The Gallery

The Gallery is a version of the shell hosted on a different domain, so that it
has no access to your regular shell. In gallery mode, nothing persists across
page loads either. It's an empty, disposable version of the shell. It's intended
to allow you to write a script and quickly publish it as a little, standalone app,
so that other people can just use it. They don't need to expose their own shells
internals to your app.

To use the Gallery, you point a browser or iframe at it, passing a Gist ID
in as a launch code. For example here's [a link][1] to the following URL:

    "https://gallery-cosh.appspot.com/#98f97a41924ca81c9863"

Note that gist hashes have the link to the gallery URL as a property named
`galleryURL`. The shell also has a function named `gallery` that takes a Gist
ID and opens it in the Gallery in new tab. Don't use the `gallery` function in
scripts though; it's unstable.

    gallery "98f97a41924ca81c9863" # handy, but currently unstable

    open clone("98f97a41924ca81c9863").galleryURL # future proof

## Shell Scripts & Naming

Users are expected to run other user's scripts [that they trust] inside their shell,
not through the Gallery. If you publish a script and need to know at runtime whether
its in shell or gallery mode, there's a global bool named `galleryMode` you can
reference.

So users can run your scripts inside their shell without clobbering stuff, you should be
very careful about what you mutate, and document it. Use standard conventions to minimise
the risk of collisions for now. A better story is being worked on.

Use the `*.coffee` extension for the keys of file chits you intend to publish as
gists. It's optional if your only running the chits yourself.

[1]: https://gallery-cosh.appspot.com/#98f97a41924ca81c9863
