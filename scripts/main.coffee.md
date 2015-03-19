# CoffeeShop

This is the main CoffeeShop file. It is loaded, compiled, cached and
executed within a function inside `boot.js`.

All the code, except for the code in `index.html`, `shell.css` and `boot.js`,
lives in this file.

This file's dependencies, `coffee`, `marked`, `pprint` and `smc` (Source Map
Consumer), are loaded by `boot.js`.

## Initialise the Global Namespace

This stuff is all exposed to users, and used internally.

First, make sure `window.indexedDB` is the correct object or `undefined`.
Users may arrive at the Gallery in any browser, so it is important to have
this when nuking the DB.

    window.indexedDB =
        indexedDB or mozIndexedDB or webkitIndexedDB or msIndexedDB

This code creates a global named `cosh` that internal stuff can be bound to,
but still be available to the user if they need it. If they often do, the
API should be extended.

    window.cosh =
        uniquePIN: 0
        coffee: coffee
        coffeeVersion: coffee.VERSION

This code sets up the API functions `uniquePIN` and `uniqueID`.

    window.uniquePIN = -> cosh.uniquePIN++

    window.uniqueID = -> "coshID" + do uniquePIN

Gallery mode is based on the URL. Port `9090` is supported on localhost for
development.

    window.galleryMode = location.host in [
        "gallery-cosh.appspot.com"
        "localhost:9090"
        ]

## Initialise the Internal Namespace

Set jQuery to not cache ajax requests, and disable the [Marked parser][1]'s
`sanitize` option.

    jQuery.ajaxSetup cache: no
    marked.setOptions sanitize: no

These are all local variables pointing to elements, most wrapped by jQuery.

    $html = jQuery "html"

    $brand = jQuery "#brand"
    $board = jQuery "#board"
    $slate = jQuery "#slate"
    $cover = jQuery "#cover"
    $clock = jQuery "#clock"
    $footer = jQuery "#footer"
    $viewer = jQuery "#viewer"
    $nameDiv = jQuery "#filename"
    $slateCount = jQuery "#slate-count"
    $editorLinks = jQuery "#editor-links"
    $descriptionDiv = jQuery "#file-description"

    clock = document.getElementById "clock"
    slateDiv = document.getElementById "slate"

This code sets up the links above the board, the *shell links*.

    jQuery("#home-link").click -> print "/docs/home.md"

    jQuery("#book-link").click -> print "/docs/front.md"

    jQuery("#more-link").click -> print "/docs/external.md"

Make CoffeeScript code clickable, to toggle compiled JavaScript code.

    $board.on "click", ".error-input-cs, .input-cs", ->

        jQuery(@).next().slideToggle(200).css display: "block"

This launches a little webworker that updates the time on the clock in
the footer div.

    worker = new Worker "/scripts/cosh/clock_worker.js"
    worker.onmessage = (event) -> $clock.text event.data

The board should only scroll while the mouse is over it.

    $board
        .on "mouseover", -> jQuery("body").css overflow: "scroll"
        .on "mouseout",  -> jQuery("body").css overflow: "hidden"

Sane truthiness test.

    bool = (thing) ->

        if thing in [undefined, null, NaN] then false
        else if (thing.equals []) or (thing.equals {}) then false
        else !! thing

The other half of the HTML escape function.

    escape = (line) ->

        line.escapeHTML()
            .split(" ").join  "&nbsp;"
            .split("\n").join "<br>"
            .split("\t").join "&nbsp;&nbsp;&nbsp;&nbsp;"

Test if a filename is Literate CoffeeScript or not.

    isLiterate = (key) -> (key.endsWith ".md") or (key.endsWith ".litcoffee")

Little helper to test if a value is a file chit. Probably needs breaking into
one for chits, one for file chits and one for gist chits, at some point.

    isFileChit = (arg) ->

        ( arg.coshKey?.isString?()            ) and
        ( arg.coshKey.length                  ) and
        ( arg.coshKey.find("\n") is undefined ) and
        ( arg.content?.isString?()            ) and
        ( arg.description?.isString?()        ) or false

Get the user platform (mac, win, linux), and create a `mac` bool for help
with defining platform specific keybindings.

    platform = navigator.platform.match(/mac|win|linux/i) or ["other"]
    platform = do platform[0].toLowerCase

    mac = platform is "mac"

## The Custom Error Types

This first takes the `UserError` implementation from [this SO answer][2] and
creates a `CoreError` constructor from it, adding a `BaseError` decorator
for enclosing the custom error type names.

    CoreError = (@message) ->

        @constructor.prototype.__proto__ = Error.prototype
        Error.captureStackTrace @, @constructor
        @name = @constructor.name

    BaseError = (type) -> (message) ->

        new CoreError "#{ type }Error: #{ message }"

Now, we can essentially just name any new error type we need. Note that this
all depends on V8. Other engines lack the `captureStackTrace` method used
by `CoreError`.

    NetError = BaseError "Net"
    AuthError = BaseError "Auth"
    GitHubError = BaseError "GitHub"
    StorageError = BaseError "Storage"
    SignatureError = BaseError "Signature"

## The Storage Functions

These are the three storage functions from [the API](/docs/storage.md). They
are exposed to users, so they all have rich error handling. See the API docs
for explanations of how they work.

The `get` method.

    window.get = (key) ->

        throw SignatureError "too few args"  if arguments.length < 1
        throw SignatureError "too many args" if arguments.length > 1
        throw TypeError "key must be a string" unless do key.isString

        if item = localStorage.getItem key then JSON.parse item
        else throw StorageError "no key named #{ key }"

The `set` method.

    window.set = (args...) ->

        reserved = (key) -> bool key.each /[*/!@:+(){}|$]/

        switch args.length

            when 2 then [key, value] = args
            when 1 then [key, value] = [args[0].coshKey, args[0]]
            when 0 then throw SignatureError "too few args"
            else throw SignatureError "too many args"

        throw SignatureError "did not find coshKey" if key is undefined
        throw SignatureError "key must be a string" unless do key.isString
        throw StorageError "#{ key } is not a valid key" if reserved key

        value.coshKey = key if value.coshKey isnt undefined
        localStorage.setItem key, JSON.stringify value
        do editor.updateCurrentFile

        return value

The `pop` method.

    window.pop = (target) ->

        throw SignatureError "too few args"  if arguments.length < 1
        throw SignatureError "too many args" if arguments.length > 1
        throw TypeError "arg must be a key string or chit" if not target

        if target.isString?() then key = target
        else if target.coshKey then key = target.coshKey
        else throw TypeError "arg must be a key string or chit"

        item = get key
        localStorage.removeItem key
        do editor.updateStatus

        return item

## The Slate

This section sets up the slate, an instance of Ace. This is also where the
code lives that allows the slate manages its input history.

First, create and configure the slate.

    window.slate = ace.edit "slate"

    slate.setShowPrintMargin false
    slate.getSession().setTabSize 4
    slate.setBehavioursEnabled false
    slate.renderer.setShowGutter false
    slate.setHighlightActiveLine false
    slate.setDisplayIndentGuides false
    slate.getSession().setUseWrapMode true
    slate.getSession().setUseSoftTabs true
    slate.setTheme "ace/theme/vibrant_ink"
    slate.session.setMode "ace/mode/coffee"

This invokes an event handler assignment that encloses a hook to the slate
document, and just resizes the slate whenever it changes.

    do ->

        doc = slate.getSession().getDocument()

        slate.on "change", ->

            slateDiv.style.height = "#{ 16 * do doc.getLength }px"
            do slate.resize
            do clock.scrollIntoView

Create the `inputs` hash that stores user input hashes, which includes source
maps, compiled JavaScript and so on. The `inputCount` just tallies the number
of user inputs.

    inputs = {}
    inputCount = 0

The `slate.history` array holds a copy of the original user inputs, and is
managed by the slate functions to remove duplicates. The `pointer` is used
to track the position in the history array during scrolls. The `stash` is
used to keep hold of what the slate buffer held before the user began
scrolling through the history array so the user can return to it.

    historyStore = "coshHistoryStore"

    try slate.history = (get historyStore) or []
    catch then slate.history = []

    pointer = slate.history.length
    stash = ""

Clicking the footer element focusses the slate, just to make it easier to
click 'on' the slate when it is small.

    $footer.click -> do slate.focus

This makes `pre` tags inside the board clickable, loading their content into
the slate.

    $board.on "click", "pre", (event) ->

        source = event.target.innerText.slice 0, -1
        if slate.getValue() isnt source then slate.push source
        else do slate.focus

This keybinding makes `Meta.Up` rewind the input history.

    slate.commands.addCommand

        name: "rewind_history"
        bindKey: win: "Ctrl-Up", mac: "Cmd-Up"
        exec: ->

            source = do slate.getValue

            if pointer >= 0 and source isnt slate.history[pointer]

                [stash, pointer] = [source, slate.history.length]

            pointer -= 1

            if pointer >= 0 then slate.setValue slate.history[pointer]
            else

                slate.setValue "# THE END OF HISTORY..."
                pointer = -1

            slate.clearSelection 1
            do clock.scrollIntoView

This keybinding makes `Meta.Down` forward the input history.

    slate.commands.addCommand

        name: "forward_history"
        bindKey: win: "Ctrl-Down", mac: "Cmd-Down"
        exec: ->

            source = do slate.getValue

            if pointer isnt -1 and source isnt slate.history[pointer]

                [stash, pointer] = [source, slate.history.length]

            pointer += 1

            if pointer < slate.history.length

                slate.setValue slate.history[pointer]

            else slate.setValue stash

            slate.clearSelection 1
            do clock.scrollIntoView

This keybinding makes `Meta.Escape` clear the board.

    slate.commands.addCommand

        name: "clear_board"
        bindKey: win: "Ctrl-Esc", mac: "Cmd-Esc"
        exec: -> $board.html ""

This keybinding makes `Meta.Dot` focus the editor.

    slate.commands.addCommand

        name: "focus_editor"
        bindKey: win: "Ctrl-.", mac: "Cmd-."
        exec: -> do editor.focus

This keybinding makes `Meta.Enter` execute the slate content.

    slate.commands.addCommand

        name: "execute_slate"
        bindKey: win: "Ctrl-Enter", mac: "Cmd-Enter"
        exec: ->

            source = slate.getValue().lines (line) -> do line.trimRight
            source = source.join "\n"
            executeSlate source if source

This keybinding makes `Meta.S` set the *editor* content to storage.

    slate.commands.addCommand

        name: "set_editor_chit"
        bindKey: win: "Ctrl-S", mac: "Cmd-S"
        exec: -> do editor.set

This keybinding makes `Meta.P` print the *editor* content.

    slate.commands.addCommand

        name: "print_editor"
        bindKey: win: "Ctrl-P", mac: "Cmd-P"
        exec: -> do editor.print

This API function resets the line history by setting the history store and
the runtime copy to empty arrays.

    slate.reset = -> set historyStore, slate.history = []

This API function pushes a string to the slate, pushing the slate content
to the input history. The push to the input history is actually done by
`slate.updateHistory` below.

    slate.push = (source) ->

        value = do slate.getValue
        slate.updateHistory value if value
        slate.setValue source
        slate.clearSelection 1
        do slate.focus

        return value

This API function is used to push inputs to the input history. It does some
housekeeping to remove an older duplicate if it exists.

    slate.updateHistory = (source) ->

        index = slate.history.indexOf source
        slate.history.splice index, 1 if index isnt -1
        pointer = slate.history.push source

## The Editor

The editor is another instance of ACE, with a few extras for displaying the
filename and description, highlighting the filename based on whether or not
the chit is different in local storage, and for executing the content.

First, create and configure the editor.

    window.editor = ace.edit "editor"

    editor.session.setMode "ace/mode/coffee"
    editor.setTheme "ace/theme/vibrant_ink"
    editor.getSession().setTabSize 4
    editor.setShowPrintMargin false
    editor.setBehavioursEnabled false
    editor.setHighlightActiveLine false
    editor.setDisplayIndentGuides false
    editor.getSession().setUseWrapMode true
    editor.getSession().setUseSoftTabs true

This hash will be updated when changes happen that could cause the file in
the editor to have changed on disk. The editor can then use this copy of the
file chit to keep the save status colour correct without worrying about the
state of localStorage.

    editor.currentFile = {}

This keybinding makes `Meta.Enter` execute the editor content.

    editor.commands.addCommand

        name: "execute_editor"
        bindKey: win: "Ctrl-Enter", mac: "Cmd-Enter"
        exec: -> do editor.run

This keybinding makes `Meta.P` print the editor content as Markdown.

    editor.commands.addCommand

        name: "print_chit"
        bindKey: win: "Ctrl-P", mac: "Cmd-P"
        exec: -> do editor.print

This keybinding makes `Meta.S` save the editor content to storage.

    editor.commands.addCommand

        name: "set_chit"
        bindKey: win: "Ctrl-s", mac: "Cmd-s"
        exec: -> do editor.set

This keybinding makes `Meta.Escape` clear the board.

    editor.commands.addCommand

        name: "clear_board"
        bindKey: win: "Ctrl-Esc", mac: "Cmd-Esc"
        exec: -> $board.html ""

This keybinding makes `Meta.Dot` focus the slate.

    editor.commands.addCommand

        name: "focus_slate"
        bindKey: win: "Ctrl-.", mac: "Cmd-."
        exec: ->

            do slate.focus
            do clock.scrollIntoView

This keybinding makes `Shift.Tab` move the focus to the description div, but
only if no code is selected, else it indents the code as Ace normally would.

    editor.commands.addCommand

        name: "focus_description"
        bindKey: win: "Shift-Tab", mac: "Shift-Tab"
        exec: ->

            if do editor.getCopyText then do editor.blockOutdent
            else do $descriptionDiv.focus

This function just gets the currently selected text, or all of the text if
nothing is currently selected, and strips any trailing whitespace.

    editor.getSource = ->

        source = do editor.getCopyText or do editor.getValue
        source = source.lines (line) -> do line.trimRight

        return source.join "\n"

This API function executes the content of the editor.

    editor.run = ->

        source = do editor.getSource

        toastr.info editor.currentFile.coshKey, "Running...", timeOut: 1000
        executeFile source, editor.currentFile.coshKey
        do clock.scrollIntoView

This API function renders the content of the editor as Markdown.

    editor.print = ->

        source = do editor.getSource
        peg.low source, "page"

        return undefined

This API function opens a chit in the editor. It is also assigned to
`window.edit` elsewhere.

    editor.edit = (target) ->

        throw SignatureError "too few args"  if arguments.length < 1
        throw SignatureError "too many args" if arguments.length > 1
        throw TypeError "arg must be a key string or chit" if not target

        if target.isString?() then item = get target
        else if target.coshKey then item = get target.coshKey
        else throw TypeError "arg must be a key string or chit"

        throw TypeError "target must be a file chit" unless item.coshKey

        editor.currentFile = item
        $nameDiv.text editor.currentFile.coshKey
        $descriptionDiv.text editor.currentFile.description

        mode = if isLiterate item.coshKey then "markdown" else "coffee"
        editor.session.setMode "ace/mode/#{ mode }"
        editor.setValue editor.currentFile.content
        do editor.updateStatus
        editor.clearSelection 1
        editor.gotoLine 1
        editor.getSession().setScrollTop 1
        do editor.focus

        return undefined

This API function sets the editor content to local storage.

    editor.set = ->

        editor.currentFile.description = do $descriptionDiv.text
        editor.currentFile.content = do editor.getValue
        set editor.currentFile
        $nameDiv.css color: "#93A538"

        return editor.currentFile

Little helper function for doing what `get` does, but without the exception
handling, returning `undefined` on bad keys, and always acting on the
local copy of `currentFile`.

    editor.getCopyFromDisk = ->

        item = localStorage.getItem editor.currentFile.coshKey
        if item then JSON.parse item else undefined

This function updates the editor state, keeping the chit status colour
correct, and keep the filename aligned with the left-hand side of the
editor when the gutter grows or shrinks.

    editor.updateStatus = ->

        lines = editor.session.getLength() + 1
        $editorLinks.css left: 623 + 7 * lines.toString().length

        inSyncWithDisk =

            ( editor.currentFile                                  ) and
            ( do editor.getValue is editor.currentFile.content    ) and
            ( editor.currentFile.equals do editor.getCopyFromDisk ) and
            ( do $descriptionDiv.text is editor.currentFile.description )

        $nameDiv.css color: if inSyncWithDisk then "#93A538" else "#E18243"

This is a little function that is called by the `set` and `pop` functions, as
they mutate local storage, to trigger a sync between editor and disk.

    editor.updateCurrentFile = ->

        if copy = do editor.getCopyFromDisk then editor.currentFile = copy
        do editor.updateStatus

A couple of event handlers that watch the editor and description divs, just
calling `editor.updateStatus` on changes.

    editor.on "change", editor.updateStatus
    $descriptionDiv.on "input", editor.updateStatus

## General Keybindings

These is where all the keybindings for outside of the slate and editor live. A
few of the common character codes are assigned to names for readability.

    [tabKey, enterKey, dotKey] = [9, 13, 190]

This is a little helper that tests whether the Meta key was active.

    modifiedKey = (event) ->

        (event.ctrlKey and not mac) or (event.metaKey and mac)

This function handles keydown events in the description div, giving the div
its keybindings.

    $descriptionDiv.bind "keydown", (event) ->

        if event.which is tabKey or event.which is enterKey

            do event.preventDefault
            return do editor.focus

        return unless modifiedKey event

        if event.which is dotKey

            do event.preventDefault
            do slate.focus

        else if do String.fromCharCode(event.which).toLowerCase is "s"

            do event.preventDefault
            do editor.set

This handles keydown events outside of the slate and editor, making
<kbd>Meta.Dot</kbd> focus the slate from anywhere.

    jQuery("body").bind "keydown", (event) ->

        return unless (event.which is dotKey and modifiedKey event)

        do event.preventDefault
        do clock.scrollIntoView
        do slate.focus

## The Shell API

This is where the bulk of the shell functions are defined. The `get`, `set`
and `pop` functions are defined earlier, as they are needed sooner.

This is just a little internal function that just tests whether a string is
a URL or not.

    remote = (path) -> "/" in path

This function just does a jQuery `scrollTop` animation to slide the top of
an element to the top of the board.

    scrollTop = ($element) ->

        animation = scrollTop: $element.offset().top - 27
        $html.animate animation, duration: 150

Make `editor.edit` available as the API `edit` function.

    window.edit = editor.edit

The `load` method was an API method, and was removed. It is still used
internally to make *blocking* requests for remote resources.

    load = (path, output=undefined) ->

        jQuery.ajax

            url: path
            async: false
            success: (goods) -> output = goods
            error: -> throw NetError "failed to load #{ path }"

        return output

The `run` method from [the API](/docs/chits.md).

    window.run = (target) ->

        resolve = (target) ->

            return [target.coshKey, target.content] unless do target.isString
            return [target, load target] if remote target
            return [target, get(target).content]

        [path, content] = resolve target

        toastr.info path, "Running...", timeOut: 1000
        executeFile content, path

The `put` and `put.low` methods from [the API](/docs/output.md). The `put`
function just effects the spacing of the output. The `put.low` function
does all the work, pretty printing and highlighting different types. The
output is then `peg`ged to the board (see below).

    window.put = (args...) ->

        boardWasNotEmpty = bool do $board.text

        $output = put.low args...
        $output?.addClass "unspaced" if boardWasNotEmpty

        return undefined

The `put.low` function wraps `peg.low`, pretty printing the `output` arg. It
does nothing if the output is `undefined`. Undefined values are never put.

    put.low = (output, callback=undefined) ->

        return do clock.scrollIntoView if output is undefined

        cssClass = "color-object"

        if output is null then output = "null"

        else if output.isDate?() then output = do output.format

        else if output.isString?()

            if output is "" then output = "empty string"
            else if do output.isBlank then output = "invisible string"
            else cssClass = "color-string"

        else output =

            try pprint.parse output
            catch then do output.toString

        peg.low jQuery("<div>"), callback
            .html escape output
            .addClass "spaced #{ cssClass }"

The `peg` and `peg.low` methods from [the API](/docs/output.md). These are
both used directy, and by other functions, notably `put` and `put.low`, to
put markup strings, DOM nodes and jQuery arrays to the board.

    window.peg = (args...) ->

        heightBeforePeg = do $board.height
        boardWasNotEmpty = bool do $board.text

        output = peg.low args...
        output.addClass "unspaced" if boardWasNotEmpty

        return unless heightBeforePeg is do $board.height

        peg.low("invisible element").attr class: "color-object"

        return undefined

    peg.low = (tree, options) ->

        $tree =

            if tree instanceof jQuery then tree
            else if tree instanceof HTMLElement then jQuery tree
            else if tree?.isString?() then jQuery("<div>").html marked tree
            else jQuery("<xmp>").html tree?.toString() or jQuery "<div>"

        if options isnt undefined

            if options.isString?() then $tree.addClass options
            else if options.isFunction?() then $tree = options $tree
            else

                $tree = options.func $tree    if options.func
                $tree.attr id: options.id     if options.id
                $tree.addClass options.class  if options.class

        if options?.target then return jQuery(options.target).append $tree
        else $board.append $tree

        if $tree[0].className is "page" then scrollTop $tree
        else do clock.scrollIntoView

        return $tree

The `print` method from [the API](/docs/output.md).

    window.print = (target) ->

        throw SignatureError "too few args"  if arguments.length < 1
        throw SignatureError "too many args" if arguments.length > 1

        if target.isString()

            throw SignatureError "arg was an empty string" unless target

            if remote target then peg.low (load target), "page"
            else peg.low get(target).content, "page"

            return undefined

        throw SignatureError "invalid argument" unless isFileChit target

        peg.low target.content, "page"

        return undefined

The `clear` method from [the API](/docs/output.md).

    window.clear = -> $board.html ""

## The GitHub Gist API

This section extends the shell API to work with gists. It starts by just
defining a couple of helpful locals.

    authStore = "coshGitHubAuth"

    gistEndpoint = (path) -> "https://api.github.com#{ path }"

This function can be called with no arguments and it will attempt to return
the GitHub credentials from storage, else `null`. It can be called with two
arguments, a username and password, and it will save them to local storage.

    auth = (args...) ->

        if args.length is 0

            try get authStore
            catch then throw AuthError "no GitHub credentials found"

        else set authStore, username: args[0], password: args[1]

This function is called to create a basic auth header string. It'll return
`null` if no credentials are found.

    authHeader = ->

        return unless authData = do auth

        authData = btoa "#{ authData.username }:#{ authData.password }"

        return Authorization: "Basic #{ authData }"

This function creates a gist chit from the JSON returned by the GitHub API.

    gist2chit = (gistHash) ->

        core = gistHash.files[gistHash.files.keys()[0]]

        coshKey: core.filename
        description: gistHash.description
        content: core.content
        gistID: gistHash.id
        owner: gistHash.owner.login
        galleryURL: "https://gallery-cosh.appspot.com/##{ gistHash.id }"

Extract a GitHub error message from a error response.

    parseGitHubError = (error) ->

        do JSON.parse(error.responseText).message.toLowerCase

This makes the auth banner link load the form defined here and binds a couple
of handlers to it.

    jQuery("#auth-link").click ->

        formID = do uniqueID

        peg.low """
            # GitHub Auth
            To publish or push to gists from cosh, you will need to provide
            your GitHub username and password.

            ## Authorise This Browser
            You credentials must be locally set to `coshGitHubAuth`.

            <form id=#{ formID }>
            <input id=#{ formID }Username type=text placeholder=username>
            <input id=#{ formID }Password type=password placeholder=password>
            <input type=submit value="set coshGitHubAuth">
            </form>

            ## Deauthorise This Browser
            You can deauthorise this browser by removing your credentials
            from local storage.

            <button id=#{ formID }Delete>pop coshGitHubAuth</button>
            """

        jQuery("##{ formID }Delete").click ->

            if localStorage.getItem authStore

                localStorage.removeItem authStore
                toastr.success "Popped coshGitHubAuth.", "Deauthorised"

            else toastr.error "Nothing at coshGitHubAuth", "Failed"

        jQuery("##{ formID }").submit (event) ->

            do event.preventDefault

            $username = jQuery "##{ formID }Username"
            $password = jQuery "##{ formID }Password"

            unless username = do $username.val

                toastr.error "Username can not be empty.", "Auth Failed"
                return do $username.focus

            unless password = do $password.val

                toastr.error "Password can not be empty.", "Auth Failed"
                return do $password.focus

            auth username, password
            toastr.success "Credentials set to coshGitHubAuth.", "Authorised"

Helper for publishing and pushing gists. This makes *blocking* requests, and
returns the results.

    gistUpdate = (type, url, data) ->

        [output, fail] = [undefined, false]

        jQuery.ajax

            async: false
            headers: do authHeader
            data: JSON.stringify data
            url: gistEndpoint url
            type: if type is "publish" then "POST" else "PATCH"
            error: (error) -> fail = error
            success: (goods) -> output = goods

        return [output, fail]

The `publish` function from the [API](/docs/gists.md).

    window.publish = (target, output=undefined) ->

        throw SignatureError "too few args"  if arguments.length < 1
        throw SignatureError "too many args" if arguments.length > 1
        throw TypeError "key must be a string" unless do target.isString

        unless target = get target then throw SignatureError "arg is not a key"

        data = description: target.description, public: true, files: {}
        data.files[target.coshKey] = content: target.content

        [result, error] = gistUpdate "publish", "/gists", data

        throw GitHubError parseGitHubError error if error

        toastr.success target.coshKey, "Published Chit"
        return set gist2chit result

The `push` function from the [API](/docs/gists.md).

    window.push = (target) ->

        throw SignatureError "too few args"  if arguments.length < 1
        throw SignatureError "too many args" if arguments.length > 1
        throw TypeError "key must be a string" unless do target.isString

        unless hash = get target then throw SignatureError "arg is not a key"

        throw GitHubError "#{ target } is unpublished" unless hash.gistID

        data = description: hash.description, files: {}

        data.files[hash.coshKey] =
            filename: hash.coshKey, content: hash.content

        [result, error] = gistUpdate "push", "/gists/#{ hash.gistID }", data

        throw GitHubError parseGitHubError error if error

        toastr.success target.coshKey, "Pushed Chit"
        return gist2chit result

The `publish` function from the [API](/docs/gists.md).

    window.clone = (gistID) ->

        [output, fail] = [undefined, false]

        jQuery.ajax

            type: "GET"
            async: false
            url: gistEndpoint "/gists/#{ gistID }"
            error: (error) -> fail = error
            success: (goods) -> output = goods

        return gist2chit output unless fail
        throw GitHubError parseGitHubError fail

The `gallery` function from the [API](/docs/publishing.md).

    window.gallery = (gistID) ->

        open "https://gallery-cosh.appspot.com/##{ gistID }"

        return undefined

The `chit` function from the [API](/docs/chits.md).

    window.chit = ->

        throw SignatureError "too few args" if arguments.length is 0
        throw SignatureError "too many args" if arguments.length > 3

        hash =
            coshKey: arguments[0]
            description: arguments[1] or ""
            content: arguments[2] or ""

        return hash if isFileChit hash

        throw SignatureError "args produced an invalid chit"

## The Page Cache

The shell preefetches docs into a cache when the user mouses over a link to
them, assuming the doc has not been cached already. This speeds things up a
lot when the user is browsing pages.

This hash is the actual cache.

    pageCache = {}

This helper gets the `href` attribute for the doc, which may end up being of
the parent node.

    getHref = (event) ->

        do event.preventDefault

        target = event.target
        href = target.href or target.parentNode.href

        if href.startsWith location.origin

            return href.slice location.origin.length

        return href

This helper sets up the logic for caching pages on hover. It will only cache
Markdown documents, and bases everything on the extension.

    $board.on "mouseover", "a", (event) ->

        path = getHref event

        return if not path.endsWith(".md") or pageCache[path]

        jQuery.get path, (page) -> pageCache[path] = page

This sets up the logic for when the user clicks a link, loading it from the
cache if it is ready, else just fetching it directly as a fallback (this is
probably not the best way to do it, but is simple and works in practice).

    $board.on "click", "a", (event) ->

        path = getHref event

        return open path unless path.endsWith ".md"

        if file = pageCache[path] then return peg.low file, "page"

        jQuery.get path, (file) ->

            pageCache[path] = file
            peg.low file, "page"

## Execution

This section is where all the compilation and evaluation lives.

This function evaluates compiled JavaScript code, setting a flag on syntax
errors, which must be inside backticked code, as the CoffeeScript compiler
does not generate code with syntax errors in.

    evaluate = (slug) ->

        try return [true, eval.call window, slug]
        catch error

            error.backtickedCode = true if error.stack.startsWith "Syntax"

        return [false, error]

This function compiles CoffeeScript source code to a compilation object,
which includes the source map. The function handles any compilation errors
itself. The return value is the compilation object (truthy) on success,
else `undefined`.

    compile = (source, literate=false) ->

        options = bare: true, sourceMap: true, literate: literate

        try return coffee.compile source, options
        catch error

            line = error.location.first_line
            column = error.location.first_column
            message = "Caught CoffeeScript #{error.name}: #{error.message}"

            jQuery "<div>"
                .attr "class", "color-operator"
                .append hilite source, line, column
                .append makeOriginDiv "invalid input [#{line+1}:#{column+1}]"
                .append makeErrorMessageDiv message
                .appendTo $board

            do clock.scrollIntoView

This function handles slate inputs. It creates the UI elements for the input
and hidden element for the compiled JavaScript too.

    window.executeSlate = (source) ->

        slate.updateHistory source
        slate.setValue ""

        return unless compilation = compile source

        inputCount++
        $slateCount.html inputCount + 1

        origin = "slate#{ inputCount }.js"

        inputs[origin] =
            shell: true
            source: source
            origin: inputCount
            native: compilation.js
            map: compilation.sourceMap

        $csSource = jQuery "<xmp>"
            .text source
            .addClass "input-cs"
            .appendTo $board

        $jsSource = jQuery "<xmp>"
            .text compilation.js
            .addClass "compiled-js"
            .appendTo $board

        slug = "#{ compilation.js }\n//# sourceURL=slate#{ inputCount }.js"

        [success, result] = evaluate slug

        if success

            put.low result, "unspaced"
            return do clock.scrollIntoView

        $csSource.attr id: inputCount
        do $jsSource.remove

        throw result

This function executes files, including the editor content when that is
executed. Note that files are timestamped, as they can be edited between
the time of the evaluation and the exception.

    executeFile = (source, url) ->

        literate = (url?.endsWith ".coffee.md") or (url?.endsWith ".litcoffee")

        date = new Date().format "{dd}:{MM}:{yyyy}@{HH}:{mm}:{ss}"
        origin = "#{ url }|#{ date }"

        return unless compilation = compile source, literate

        inputs[origin] =
            shell: false
            source: source
            origin: origin
            native: compilation.js
            map: compilation.sourceMap

        slug = "#{ compilation.js }\n//# sourceURL=#{ origin }"

        [success, result] = evaluate slug

        throw result unless success

## Exception Handling

This section is where runtime errors get caught and stacktaces are generated.

This is the error highlighter. It takes a string of source code, and a line
and column number, and returns a jQuery element for the source code with the
offending character wrapped in the correct class. Missing characters, like a
closing paren, are replaced with an underlined space.

    hilite = (source, lineNumber, charNumber) ->

        lines = do source.lines
        line  = lines[lineNumber]
        start = escape line.slice 0, charNumber
        end   = escape line.slice charNumber + 1
        char  = line[charNumber]
        look  = if char then "color-operator" else "error-missing-char"
        char  = if char then escape char else "&nbsp;"

        lines[lineNumber] = "#{start}<span class=#{look}>#{char}</span>#{end}"

        for line, index in lines

            lines[index] = escape line if index isnt lineNumber

        jQuery("<span class=error>").html lines.join "<br>"

This takes an item and a map of line and column numbers, and creates the
origin banner that goes at the bottom of each item in a traceback. It
handles executed files and shell inputs differently.

    parseOrigin = (item, line, column) ->

        locationString = "[#{ line + 1 }:#{ column + 1 }]"

        return "#{ item.origin } #{ locationString }" if item.shell

        [key, date] = item.origin.split "|"

        return "#{ key } #{ locationString } [#{ date }]"

This is a helper that takes an error's origin, basically a path to a file or
shell input, and returns a jQuery div. Every item in a rendered error has one
of these divs beneath it.

    makeOriginDiv = (origin) ->

        jQuery "<div>"
            .html "<span class=trace-counter>#{ origin }</span><br><br>"

This helper is for making a jQuery div for a JavaScript error item. Because
the JavaScript errors generally do not have source code available, untill
workarounds are implemented, JavaScript items in tracebacks do not include
source code.

    makeErrorMessageDiv = (message) ->

        jQuery("<xmp>").text(message).addClass "error-message unspaced"

The `window.onerror` function. This is where all runtime errors end up.

    window.onerror = (message, url, line, column, error) ->

        if error.backtickedCode then message = "Lost #{ message }"

        divStack = []

        for trace in parseTrace error.stack

            if item = inputs[trace.file] # ================= # if coffee source

                mapper = new smc.SourceMapConsumer do item.map.generate
                jsPosition = line: trace.lineNumber, column: trace.column-1
                csPosition = mapper.originalPositionFor jsPosition
                csPosition = [csPosition.line-1, csPosition.column]

                origin = parseOrigin item, csPosition...

                $cs = hilite item.source, csPosition...
                $js = hilite item.native, trace.lineNumber-1, trace.column-1

                $item = jQuery "<div>"
                    .css "display": "inline"
                    .append $cs.addClass "error-input-cs"
                    .append $js.addClass "error-compiled-js"

            else # ===================================== # if javascript source

                origin = trace.file

                $item = jQuery """
                    <div><span class=error>JavaScriptError in
                    <span class=color-operator>#{ trace.methodName }</span>
                    [#{ trace.lineNumber }:#{ trace.column }]
                    </span></div>
                    """

            $item.append makeOriginDiv origin
            divStack.push $item

        $stackDiv = jQuery "<div>"
            .append do divStack.reverse
            .append makeErrorMessageDiv message

        $input = jQuery "##{ inputCount }"

        if $input.length then $input.replaceWith $stackDiv
        else $board.append $stackDiv

        do clock.scrollIntoView

### The Traceback Parser

This parses the stacktrace string that is passed to `window.onerror` as
`error.stack`, converting it into an array of hashes, each an item from the
stack. It returns an array of two objects, the stack array it creates, and a
bool, which is truthy if the stacktrace fails to reach the `limit`, which is
basically this file, and false otherwise. Traces are truncated to remove any
internal cruft.

This code is taken from [StackTrace-Parser][3] by `errwischt` on GitHub.

    parseTrace = (traceback) ->

        stack = []
        lines = traceback.split "\n"

        ignore = (url) ->

            ( url is "/cosh/main.js" ) or
            ( url.startsWith "#{ location.origin }/scripts" )

        gecko = /^(?:\s*(\S*)(?:\((.*?)\))?@)?((?:file|http|https).*?):(\d+)(?::(\d+))?\s*$/i
        node = /^\s*at (?:((?:\[object object\])?\S+(?: \[as \S+\])?) )?\(?(.*?):(\d+)(?::(\d+))?\)?\s*$/i
        chrome = /^\s*at (?:(?:(?:Anonymous function)?|((?:\[object object\])?\S+(?: \[as \S+\])?)) )?\(?((?:file|http|https):.*?):(\d+)(?::(\d+))?\)?\s*$/i

        for line in lines

            if parts = chrome.exec line

                continue if ignore parts[2]

                element =
                    file: parts[2].remove /[()]/g
                    methodName: parts[1] or "<unknown>"
                    lineNumber: +parts[3]
                    column: (if parts[4] then +parts[4] else null)

            else if parts = node.exec line

                continue if ignore parts[2]

                element =
                    file: parts[2].remove /[()]/g
                    methodName: parts[1] or "<unknown>"
                    lineNumber: +parts[3]
                    column: (if parts[4] then +parts[4] else null)

            else if parts = gecko.exec line

                continue if ignore parts[3]

                element =
                    file: parts[3].remove /[()]/g
                    methodName: parts[1] or "<unknown>"
                    lineNumber: +parts[4]
                    column: (if parts[5] then +parts[5] else null)

            else continue

            stack.push element

        return stack

## Launch Shell

This is the last section of cosh code to run as the shell boots. It will run
any config or user script once it is set up.

First, light up the favicon's eyes, and raise a toast. Everything after this
depends on the mode.

    jQuery("#favicon").attr href: "/images/skull_up.png"

    toastr.info(
        "Powered by CoffeeScript (#{ coffee.VERSION })"
        "CoffeeShop: The HTML5 Shell"
        timeOut: 1600
        )

### Gallery Mode

If the shell is in gallery mode, then storage needs nuking. This is done now
and again on unload so that if the `onunload` function gets edited, nothing
will persist beyond the next boot, making it pointless to hack `onunload`.

Then the gist specified in the launch code is cloned ~ a fallback gist is used
if a valid gist id is not provided. The gist is then loaded into the editor
and executed.

    if galleryMode

        do window.onunload = ->

            do localStorage?.clear
            do sessionStorage?.clear
            indexedDB?.deleteDatabase "*"

        fallback = "9419b50cdaa7238725d8"
        window.mainFile = (clone launchCode or fallback) or (clone fallback)
        edit set mainFile
        do editor.run

        $brand.text("CoffeeShop Gallery").css color: "#E18243"

### Shell Mode

If the shell is not in gallery mode, it needs to check that the config file
exists, and create it otherwise. It then opens the config file in the editor
and executes it.

If the launch code `safemode` is used, the config is loaded into the editor,
but not executed.

The `onunload` function is also set up to write the input history to local
storage when the page is destroyed.

    if not galleryMode

        window.onunload = ->

            set historyStore, slate.history.last 400
            return undefined

        try get "config.coffee"
        catch then set

            coshKey: "config.coffee",
            description: "Run on boot unless in safe mode."
            content: 'print "/docs/home.md"'

        safemode = launchCode is "safemode"

        $brand
            .css( color: if safemode then "#D88E5C" else "#93A538" )
            .text( if safemode then "Safe Mode" else "c[_]" )

        edit "config.coffee"
        run "config.coffee" unless launchCode is "safemode"

### The End

All done; just focus the slate. The comment at the bottom is a source URL
directive that allows the shell to recognise this file in stacktraces, so
the stack can be filtered correctly.

    do slate.focus

    `//# sourceURL=/cosh/main.js
    `

[1]: https://github.com/chjj/marked
[2]: http://stackoverflow.com/a/8460753/1253428
[3]: https://github.com/errwischt/stacktrace-parser

<img src=/images/skull_up.png style=padding:0>
<span style=vertical-align:4px;margin-left:-1px>PS84 &copy; 2015 GPLv3</span>
