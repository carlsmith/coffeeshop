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

[CoffeeShop][1] is a CoffeeScript shell. It works like a regular shell, but
exposes the browser runtime, not the underlying operating system.

> "pretty bad ass" -- Jeremy Ashkenas

[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/carlsmith/coffeeshop?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

### Brags

- **HTML5 Shell** Everything you can do in a browser, in a shell.
- **Ace Editing** The shell and editor are both instances of Ace.
- **Smart Tracebacks** Automatic source mapping. Just debug the code you wrote.
- **Transpection** Click on any CoffeeScript in the shell to see the compiled JS.
- **Extensible** CoffeeShop is easy to hack from inside itself.
- **Gist Integration** Publish, push and clone scripts through GitHub.
- **Online Gallery** Share your scripts as mini webapps.
- **Fully Literate** Seamless Literate CoffeeScript support.
- **Sweet Runtime** SugarJS and jQuery are preinstalled.
- **Origin Agnostic** CORS based. You can host CoffeeShop anywhere.
- **No Dependencies** CoffeeShop builds itself from source.
- **Documented** Interactive documentation inside the shell.
- **Free as in Free** GPL licensed and gratis.

### Getting Started

[The Shell][1] and the Gallery are hosted on Google App Engine. You are
welcome to just use them, no problem. If you'd rather not share with Google,
or you just want to hack on the core, you can host you own instances, privately
or publicly, very easily.

The entire application is just a bunch of static files, so you can serve it
from any server, locally or online. Cosh only uses cross origin services, so
the app will work the same way however it's hosted. Note that local storage is
always per-origin.

If you'd like to hack on the CoffeeScript and Markdown source, you also only
need a static file server on your local machine; there are no dependencies or
build tools. You just  append `#build` to the shells URL, and the shell will
rebuild itself from source each time you reload it. For example:

    http://localhost:8080#build

If you host your dev server at `localhost:9090`, it will serve in gallery mode.
In gallery mode, the app always builds from source, as nothing persists.

Note: If you put an infinite loop or something in your config, you can use
the `safemode` launch code to boot the shell with a freshly compiled core
and without running your config file. For example:

    https://shell-cosh.appspot.com#safemode

If you want to publish or push to GitHub Gist, you'll need a GitHub account.
CoffeeShop doesn't have an account system; it just uses local storage.

### Limitations

You must use a V8 based browser (Chromium, Chrome or Opera). FireFox support
is also possible and is planned.

### Status

Everything works, and is pretty stable, but a couple of minor bits may change
before things properly settle down. The version on App Engine is always in
sync with this repo, for better or worse, so expect the occasional fail.

Experienced programmers should find CoffeeShop useful now. The support for
new programmers is being worked on.

### License

CoffeeShop is Free Software. A lot of CoffeeShop's parts come from third party
projects under their chosen [open source] licenses. All code and docs in this
repository are bundled together under the [GPLv3][3] for convenience.

![logo](https://raw.githubusercontent.com/carlsmith/coffeeshop/master/images/skull_stamp.png)

[1]: https://shell-cosh.appspot.com "CoffeeShop"
[3]: http://www.gnu.org/licenses/gpl-3.0.html "GNU General Public License v3"
