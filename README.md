
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

- **Based on Ace** Supports multiline input, syntax highlighting and
everything else that Ace provides.
- **CoffeeScript Tracebacks** You never need to debug compiled JavaScript.
- **Fully Scriptable** Edit scripts in local storage. Includes a config
file that gets executed each time the shell loads.
- **Gists** Publish, push, pull and clone scripts through GitHub. All
published scripts can be executed by every user.
- **Gallery Mode** A stripped down, sanitised version of the shell, running
on its own domain, that allows anyone to wrap published gists as little,
standalone webapps, with a URL you can share or point iframes at.
- **Shell Foo** Cosh provides a collection of functions that use
CoffeeScript's optional brackets syntax to provide an API that feels a lot like
shell scripting.
- **Extended Runtime** The SugarJS Library is applied wholesale, so native
types all have awesome methods out the box. You also have jQuery. Obviously.
- **Built In Docs** Cosh has built in docs that are interactive and use
Markdown.

Set Up
------

[The Shell][1] and the Gallery are hosted on Google App Engine. You're
welcome to use them ~ problem solved. If you'd rather not share personal
data with Google, you can host you own nodes, locally or online, very
easily.

The entire application is just static files, and it compiles itself when it
boots. This allows you to serve it with any static file server, and to hack
on the CoffeeScript and Markdown source without installing any dependencies
or build tools. Cosh will also only ever use cross origin services, so the
app will work the same way however it's hosted. Note that local storage is
always per-origin.

If you want to publish or push to GitHub Gist, you'll need a GitHub
account. CoffeeShop has no account system; it just uses local storage.

Limitations
-----------

Only Chrome and Opera currently have the features needed to create tracebacks,
so you'll need one of those to use the shell. The Gallery should work in any
browser.

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
