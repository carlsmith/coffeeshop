
     .d8888b.          .d888 .d888                 .d8888b. 888                       888
    d88P  Y88b        d88P" d88P"                 d88P  Y88b888                       888
    888    888        888   888                   Y88b.     888                       888
    888        .d88b. 888888888888 .d88b.  .d88b.  "Y888b.  88888b.  .d88b. 88888b.   888
    888       d88""88b888   888   d8P  Y8bd8P  Y8b    "Y88b.888 "88bd88""88b888 "88b  888
    888    888888  888888   888   8888888888888888      "888888  888888  888888  888  888
    Y88b  d88PY88..88P888   888   Y8b.    Y8b.    Y88b  d88P888  888Y88..88P888 d88P   "
     "Y8888P"  "Y88P" 888   888    "Y8888  "Y8888  "Y8888P" 888  888 "Y88P" 88888P"   888
                                                                            888
                      COSH ~ A BETTER COFFEESCRIPT SHELL                    888
                                                                            888

[CoffeeShop][1] [cosh] is a HTML5 shell for CoffeeScript hacking.

- **HTML5 Shell** Everything you can do in a browser. In a shell.
- **Based on Ace** Supports multiline input, syntax highlighting and everything else
that Ace provides.
- **Tracebacks** You never need to debug compiled JavaScript.
- **Hackable** Edit scripts in local storage, including a config file that
gets executed each time the shell loads.
- **Gist Integration** Publish, push and clone scripts through GitHub. All published
scripts can be cloned by every user.
- **Show Off** There's a special version of the shell you can share by URL. It allows
anyone to wrap published gists as little, standalone web scripts. You can share example
code, like JSFiddle, or just do Astroids again.
- **Shell Foo** Cosh defines a small collection of functions that use CoffeeScript's
optional parens syntax to provide an API that's like shell scripting, but about ten
times more ninja.
- **Sweet Runtime** The SugarJS Library is applied wholesale, so native types all
have awesome methods out the box. You also have jQuery. Obviously.
- **Documented** Built in, interactive documentation, using Markdown.
- **Self Compiling** Cosh is able to build itself from source on page load, so you can
hack on the core without installing any dependencies, even on Windows.

Set Up
------

[The Shell][1] and the Gallery are hosted on Google App Engine. You're
welcome to use them ~ problem solved. If you'd rather not share personal
data with Google, you can host you own instances, privately or publicly,
very easily.

The entire application is just static files, so you can serve it from any
static file server, locally or online. Cosh only uses cross origin services,
so the app will work the same way however it's hosted. Note that local storage
is always per-origin.

If you'd like to hack on the CoffeeScript and Markdown source, you also only
need a static file server on your local machine; you don't need to install any
dependencies or build tools. You can append `#build` to the shells URL, and the
shell will rebuild itself from source each time you reload the page. For example:

    http://localhost:8080#build

If you host your dev server at `localhost:9090`, it'll serve in gallery mode. In
gallery mode, the app always builds from source, as nothing persists.

Note: If you put an infinite loop or something in your config, you can use the
`safemode` launch code to boot the shell with a freshly compiled core and without
running your config file.

    https://shell-cosh.appspot.com#safemode

Account
-------

If you want to publish or push to GitHub Gist, you'll need a GitHub account.
CoffeeShop has no account system; it just uses local storage.

Limitations
-----------

Only Chrome and Opera currently have the features needed to create tracebacks,
so you'll need one of those to use the shell.

The app's just been released. All the core features have been implemented and are
pretty stable and documented. It's just a matter of testing things really.

The docs still need some work. They cover using the app itself pretty well, but the
CoffeeScript Language stuff is still really sketchy in places. The docs are being
worked on currently. There's good CoffeeScript docs online already, and it's a very
easy ~ and fun ~ language to learn if you already know JavaScript.

License
-------

CoffeeShop is Free Software. A lot of CoffeeShop's parts come from third party
projects under their chosen [open source] licenses. All code and docs in this
repository are bundled together under the [GPLv3][2] for convenience. Better
licensing can be worked out.

---

- [shell-cosh.appspot.com][1] Our instance, hosted on Google App Engine.

[1]: https://shell-cosh.appspot.com/ "CoffeeShop"
[2]: http://www.gnu.org/licenses/gpl-3.0.html "GNU General Public License v3"
