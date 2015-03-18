# Publishing

Once a chit is published as a Gist, you or anyone else can run the script
in your shell, as easy as...

    run clone "98f97a41924ca81c9863"

Doing this **can be dangerous**. You are trusting the person who wrote the
code not to do bad stuff.

## The Gallery

The Gallery is a version of the shell hosted on a different domain, so that it
has no access to your regular shell. In gallery mode, nothing persists across
page loads. It is an empty, disposable version of the shell.

To use the Gallery, you point a browser or iframe at it, passing a Gist ID
in as a launch code. For example, here is [a link][1] to the following URL:

    https://gallery-cosh.appspot.com/#98f97a41924ca81c9863

Note that all gist chits have a link to their gallery URL as a property named
`galleryURL`. You can use the `gallery` function to open any published gist
in a new tab.

    gallery "98f97a41924ca81c9863"

## Shell Scripts & Naming

Users are expected to run other user's scripts [that they trust] inside their
shell. If you publish a script and it needs to know at runtime whether it is
in shell or gallery mode, there is a global bool named `galleryMode` you can
reference.

So users can run your scripts inside their shell without clobbering stuff,
you should be very careful about what you mutate, and document it.

Use the `*.coffee` or `*.coffee.md` patterns for the keys of chits you intend
to publish as gists. It is optional if your only running the scripts locally.

Have fun `:)`

[1]: https://gallery-cosh.appspot.com/#98f97a41924ca81c9863
