
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
- **CoffeeScript Tracebacks** You never need to debug compiled JavaScript.
- **Totally Hackable** Edit scripts in local storage, including a config file that
gets executed each time the shell loads.
- **GitHub Gist Integration** Publish, push, pull and clone scripts through GitHub.
All published scripts can be executed by every user.
- **Showing Off** There's a sanitised version of the shell, running on its own domain,
that allows anyone to wrap published gists as little, standalone web apps, with a URL
you can share and point iframes at.
- **Kung Foo** Cosh defines a small collection of functions that use CoffeeScript's
optional parens syntax to provide an API that's like shell scripting, but about ten
times more ninja.
- **Sweet Runtime** The SugarJS Library is applied wholesale, so native types all
have awesome methods out the box. You also have jQuery. Obviously.
- **Magic Docs** Built in, interactive documentation, using Markdown.
- **Trampy Server** Cosh only uses static files and CORS. It will happily live anywhere.
- **Self Compiling** Cosh is able to build itself from source on page load, so you can
hack on the core without installing any dependencies, even on Windows.
- **Other Stuff** It's free to use and open source. If you're not interested enough by
this point to click a link and try it, you're in the wrong place.

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

The app's still pre-release, but it's ready now. All the core features have
been implemented and are stable and documented.

The code base has been heavily refactored recently, so there may be minor
bugs from that work that still need shaking out. Report them and they'll be
looked at immediately.

The docs are still being worked on, and should be of a minimal viable quality
within days.

Status
------

The current effort is towards testing everything and finishing the built in docs. Once
that's done, the app will hit the Version One milestone. The plan is to start plugging
CoffeeShop at that point, gathering more users and getting their feedback. During this
time, the code will be converted to use Literate CoffeeScript, and properly documented
so it's easy to hack on. No new features will be added until that's done.

The docs can never be good enough, so that'll be ongoing work.

Once the source is properly documented, which shouldn't take long ~ it's only about 800
lines of spacious CoffeeScript ~ then new features can be looked at, once there's a few
people to discuss them

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
