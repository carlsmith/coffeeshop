```
  .d8888b.          .d8888888888888888888888P" .d8888b. .d88888888888888888888888888
 d88P  Y88b        d88Y  d88Y                 d88P  Y88Y88Y                      888
 888    888        888   888                  Y88b.    888                       888
 888        .d88b. 8888888888P".d88b.  .d88b. "Y888b.  88888b.  .d88b. 88888b.   888
 888       d88""88b888   888  d8P  Y8bd8P  Y8b   "Y88b.888 "88bd88""88b888 "88b  888
 888    888888  888888   888  8888888888888888     "888888  888888  888888  888  888
 Y88b  d88PY88..88P888   888  Y8b.    Y8b.   Y88b  d88P888  888Y88..88P888 .d8P  
  "Y8888P"  "Y88P" 888   888   "Y8888  "Y8888 "Y8888P" 888  888 "Y88P" 88888P"   GPL
                   888   888                           888  888        888
                  .d8Y  .d8Y  c[__] THE HTML5 SHELL   .d8Y .d8Y       .d8Y
```

![screenshot](https://raw.githubusercontent.com/carlsmith/coffeeshop/master/images/props.png)

[CoffeeShop][1] is a gist based environment for web scripting. It lets you make and
publish HTML5 shell scripts using CoffeeScript and Markdown.

> "pretty bad ass" -- Jeremy Ashkenas

[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/carlsmith/coffeeshop?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

### Main Awesomeness

- **HTML5 Shell** Everything you can do in a browser, in a CoffeeScript shell.
- **Ace Editing** The shell and editor are both based on Ace and easy to hack.
- **Smart Tracebacks** Automatic source mapping. Just debug the code you wrote. Click
on any CoffeeScript in a traceback to see the compiled JS.
- **Extensible** Edit scripts in local storage, including code that gets executed each
time the shell loads. Hack the shell from inside of itself and make it your own.
- **Gist Integration** Publish, push and clone scripts through GitHub. All published
scripts can be cloned and run by every user.
- **Safe and Easy Sharing** A special version of the shell, the Gallery, allows you to
share your scripts as mini webapps. It's a bit like JSFiddle or CodePen, but focuses on
complete scripts that actually *do* stuff.
- **Fully Literate** Everything is Markdown based, and Literate CoffeeScript support is
baked in. You can easily create interactive docs and [blog posts][2] as web scripts too.
- **Coffee Foo** Built in collection of ninja utility functions.
- **Sweet Runtime** The SugarJS Library is applied wholesale, so native types all
have awesome methods out the box. You also have jQuery. Obviously.
- **Documented** Built in, simple, interactive documentation to get you up to speed.
- **Origin Agnostic** Everything is based around CORS, so you can host an instance
anywhere [including locally] and it'll work the same as ever.
- **Self Compiling** Cosh is able to build itself from source, so you can hack on the
core without installing any dependencies, even on Windows.
- **Free as in Free** GPL licensed and gratis.

### Getting Started

[The Shell][1] and the Gallery are hosted on Google App Engine. You're welcome to use
them, no problem. If you'd rather not share personal data with Google, or you just want
to hack on the core, you can host you own instances, privately or publicly, very easily.

The entire application is just static files, so you can serve it from any static file
server, locally or online. Cosh only uses cross origin services, so the app will work
the same way however it's hosted. Note that local storage is always per-origin.

If you'd like to hack on the CoffeeScript and Markdown source, you also only need a
static file server on your local machine; you don't need to install any dependencies
or build tools. You can append `#build` to the shells URL, and the shell will rebuild
itself from source each time you reload the page. For example:

    http://localhost:8080#build

If you host your dev server at `localhost:9090`, it'll serve in gallery mode. In
gallery mode, the app always builds from source, as nothing persists.

Note: If you put an infinite loop or something in your config, you can use the
`safemode` launch code to boot the shell with a freshly compiled core and without
running your config file.

    https://shell-cosh.appspot.com#safemode

If you want to publish or push to GitHub Gist, you'll need a GitHub account.
CoffeeShop doesn't have an account system; it just uses local storage.

### Limitations

Browsers suck a stack traces, especially in what they expose to webapps. Only
Chrome and Opera currently have the features needed to create tracebacks well,
so you'll need one of those browsers for now.

Browser limitations on tracebacks also mean you must use CoffeeScript, not
native JavaScript, though the features needed to directly support JavaScript
are implemented and will be in stable Chrome very soon.

FireFox support, for both CoffeeScript and JavaScript, will probably take a
little longer, but should be possible within a few months.

Other browsers are not likely to work well with CoffeeShop in the near future.

TLDR: You'll soon be able to use any mix of CoffeeScript and JavaScript in
Chrome, Opera and FireFox, but for now it's CoffeeScript in Chrome and Opera.

### License

CoffeeShop is Free Software. A lot of CoffeeShop's parts come from third party
projects under their chosen [open source] licenses. All code and docs in this
repository are bundled together under the [GPLv3][3] for convenience.

> "legend tells of a legendary warrior whose kung fu skills were the stuff of legend" -- Po

![logo](https://raw.githubusercontent.com/carlsmith/coffeeshop/master/images/skull_stamp.png)

[1]: https://shell-cosh.appspot.com/ "CoffeeShop"
[2]: https://gallery-cosh.appspot.com/#2527b9a1d347a747be49 "ES6 Rant"
[3]: http://www.gnu.org/licenses/gpl-3.0.html "GNU General Public License v3"
