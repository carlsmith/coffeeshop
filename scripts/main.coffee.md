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

    $brand = jQuery "#brand"
    $slate = jQuery "#slate"
    $clock = jQuery "#clock"
    $board = jQuery "#board"
    $cover = jQuery "#cover"
    $viewer = jQuery "#viewer"
    $nameDiv = jQuery "#filename"
    $editorLinks = jQuery "#editor-links"
    $descriptionDiv = jQuery "#file-description"

    clock = document.getElementById "clock"
    slateDiv = document.getElementById "slate"

This code sets up the links above the board, the *shell links*.

    jQuery("#home-link").click -> print "/docs/home.md"

    jQuery("#book-link").click -> print "/docs/front.md"

    jQuery("#more-link").click -> print "/docs/external.md"

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

Test if a filename is Literate CoffeeScript or not.

    isLiterate = (key) -> (key.endsWith ".md") or (key.endsWith ".litcoffee")

The other half of the HTML escape function.

    escape = (line) ->

        line.escapeHTML()
            .split(" ").join  "&nbsp;"
            .split("\n").join "<br>"
            .split("\t").join "&nbsp;&nbsp;&nbsp;&nbsp;"

## The Custom Error Types

This first takes the `UserError` implementation from [this SO answer][2] and
creates a `CoreError` constructor from it, adding a `BaseError` decorator
for enclosing the custom error type names.

    CoreError = (@message) ->

        @constructor.prototype.__proto__ = Error.prototype
        Error.captureStackTrace(@, @constructor)
        @name = @constructor.name

    BaseError = (type) ->

        (message) -> new CoreError "#{ type }Error: #{ message }"

Now it is simple to create new error types.

    StorageError   = BaseError "Storage"
    SignatureError = BaseError "Signature"

## The Storage Functions

These are the three storage functions from [the API](/docs/storage.md). They
are exposed to users, so they all have rich error handling.

The `get` method.

    window.get = (key) ->

        throw SignatureError "too few args"  if arguments.length < 1
        throw SignatureError "too many args" if arguments.length > 1
        throw TypeError "key must be a String" unless do key.isString

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
        throw SignatureError "key must be a String" unless do key.isString
        throw StorageError "invalid key `#{ key }`" if reserved key

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

This just resizes the slate on changes.

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
    slate.history = (get historyStore) or []
    pointer = slate.history.length
    stash = ""

Clicking the footer element focusses the slate, just to make it easier to
click 'on' the slate when it is small.

    jQuery('#footer').click -> do slate.focus

This makes `pre` tags inside the board clickable, loading their content into
the slate.

    jQuery("#board").on "click", "pre", (event) ->

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
        exec: -> board.innerHTML = ""

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
            cosh.execute source if source

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
        slate.focus()

        return value

This API function is used to push inputs to the input history. It does some
housekeeping to remove an older duplicate if it exists.

    slate.updateHistory = (source) ->

        index = slate.history.indexOf source
        slate.history.splice(index, 1) if index isnt -1
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
        exec: -> board.innerHTML = ""

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

            if editor.getCopyText() then editor.blockOutdent()
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
        cosh.execute source, editor.currentFile.coshKey
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

Little helper function for doing what `get` does without the exception
handling, and always on the local copy of `currentFile`.

    editor.getCopyFromDisk = ->

        item = localStorage.getItem editor.currentFile.coshKey
        JSON.parse item if item

This function updates the editor state, keeping the chit status colour
correct, and keep the filename aligned with the left-hand side of the
editor when the gutter grows or shrinks.

    editor.updateStatus = ->

        lines = editor.session.getLength() + 1
        $editorLinks.css left: 623 + 7 * lines.toString().length

        inSync =

            ( editor.currentFile ) and
            ( do editor.getValue is editor.currentFile.content ) and
            ( editor.currentFile.equals do editor.getCopyFromDisk ) and
            ( do $descriptionDiv.text is editor.currentFile.description )

        $nameDiv.css color: if inSync then "#93A538" else "#E18243"

This is a little function that is called by the `set` and `pop` functions, as
they mutate local storage, to trigger a sync between editor and disk.

    editor.updateCurrentFile = ->

        if copy = do editor.getCopyFromDisk then editor.currentFile = copy
        do editor.updateStatus

A couple of event handlers that watch the editor and description divs, just
calling `editor.updateStatus` on changes.

    editor.on "change", editor.updateStatus
    $descriptionDiv.on "input", editor.updateStatus

This handles keydown events in the description div, giving the div its
keybindings. It is a bit hacky: Control and Command key works on OS X.

    $descriptionDiv.bind "keydown", (event) ->

        if event.which is 9 or event.which is 13

            do event.preventDefault
            return do editor.focus

        return unless (event.ctrlKey or event.metaKey)

        if event.which is 190

            do event.preventDefault
            return do slate.focus

        if do String.fromCharCode(event.which).toLowerCase is "s"

            do event.preventDefault
            do editor.set

## The Shell API

Make `editor.edit` a global as the API `edit` function.

    window.edit = editor.edit

This function is used to decide whether a string is a URL or not.

    remote = (path) -> "/" in path

The `run` method from [the API](/docs/files.md).

    window.run = (target) ->

        if do target.isString
            path = target
            content =
                if remote target then load target
                else get(target)?.content
        else [path, content] = [target.coshKey, target.content]

        if path and content?
            toastr.info path, "Running Chit", timeOut: 1000
            cosh.execute content, path
        else toastr.error "No file hash at #{target}.", "Run Failed"

        undefined

The `put` method from [the API](/docs/output.md).

    window.put = (args...) ->

        boardWasNotEmpty = bool do $board.text
        output = put.low args...
        output?.addClass "unspaced" if boardWasNotEmpty
        undefined

    put.low = (args...) ->

        arg = args[0]
        color = "color-object"

        if arg is null then arg = "null"
        else if arg is undefined then return do clock.scrollIntoView
        else if arg.isDate?() then arg = arg.format()
        else if arg.isString?()
            if arg is "" then arg = "empty string"
            else if arg.isBlank() then arg = "invisible string"
            else color = "color-string"
        else
            try arg = pprint.parse(arg)
            catch error then arg = arg.toString()

        peg.low jQuery("<div>"), args[1]
            .addClass color
            .addClass "spaced"
            .html escape arg

The `peg` method from [the API](/docs/output.md).

    window.peg = (args...) ->

        heightBeforePeg = $board.height()
        boardWasNotEmpty = bool $board.text()
        output = peg.low args...
        output.addClass "unspaced" if boardWasNotEmpty
        return if heightBeforePeg isnt $board.height()
        peg.low("invisible element").attr class: "color-object"
        undefined

    peg.low = (tree, options) ->

        $tree =

            if tree instanceof jQuery
                tree
            else if tree instanceof HTMLElement
                jQuery tree
            else if tree?.isString?()
                jQuery("<div>").html marked tree
            else
                jQuery("<xmp>").html tree?.toString() or jQuery "<div>"

        if options isnt undefined

            if options.isString?() then $tree.addClass options
            else if options.isFunction?() then $tree = options $tree
            else

                $tree = options.func $tree    if options.func
                $tree.attr id: options.id     if options.id
                $tree.addClass options.class  if options.class

        if options?.target then return jQuery(options.target).append $tree
        else $board.append $tree

        if $tree[0].className isnt "page" then do clock.scrollIntoView
        else jQuery("html").animate(
            { scrollTop: $tree.offset().top - 27 }
            { duration: 150 }
            )

        $tree

The `load` method was an API method, and is no more. It's still used internally
to make blocking requests for remote resources.

    load = (path, callback=undefined) ->

        output = undefined

        jQuery.ajax
            url: path
            async: bool callback
            success: (response) ->
                if callback then callback response else output = response

        output

The `print` method from [the API](/docs/output.md).

    window.print = (target) ->

        if target.isString()
            if remote target
                if data = load target then peg.low data, "page"
                else toastr.error "#{target} not found", "View Failed"
            else if data = get target then peg.low data.content, "page"
        else peg.low target.content, "page"

        undefined

The `view` function.

    windowHeight = undefined
    do setWindowHeight = -> windowHeight = jQuery(window).height()
    jQuery(window).resize setWindowHeight

    window.view = (content) ->

        peg content, target: $viewer
        $viewer.css maxHeight: windowHeight-127, display: "block"
        $cover.css display: "block"
        undefined


The `clear` method from [the API](/docs/output.md).

    window.clear = -> $board.html("").shush

## The GitHub Gist API

This section extends the shell API to work with gists. It starts by just
defining a couple of helpful locals.

    authStore = "coshGitHubAuth"
    gistEndpoint = (path) -> "https://api.github.com#{path}"

This function can be called with no arguments and it'll attempt to return the
GitHub credentials for the browser, else `null`. I can be called with two
arguments, a username and password, and it'll save them to local storage.

    auth = (args...) ->

        if args.length is 0
            authHash = get(authStore) or sessionStorage.getItem(authStore)
            if authHash?.isString() then JSON.parse authHash else authHash
        else set authStore, { username: args[0], password: args[1] }

This function is called to create a basic auth header string. It'll return
`null` if no credentials are found.

    authHeader = ->

        return unless authData = do auth
        authData = btoa "#{authData.username}:#{authData.password}"
        Authorization: "Basic #{authData}"

This function creates a gist chit from the JSON returned by the GitHub API.

    gist2chit = (gistHash) ->

        core = gistHash.files[gistHash.files.keys()[0]]
        chit
            coshKey: core.filename
            description: gistHash.description
            content: core.content
            gistID: gistHash.id
            owner: gistHash.owner.login
            galleryURL: "https://gallery-cosh.appspot.com/##{gistHash.id}"

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

            <form id=#{formID}>
            <input id=#{formID}Username type=text placeholder=username>
            <input id=#{formID}Password type=password placeholder=password>
            <input type=submit value="set coshGitHubAuth">
            </form>

            ## Deauthorise This Browser
            You can deauthorise this browser by removing your credentials
            from local storage.

            <button id=#{formID}Delete>pop coshGitHubAuth</button>
            """

        jQuery("##{formID}Delete").click -> if pop authStore
            toastr.success "Popped coshGitHubAuth.", "Deauthorised"

        jQuery("##{formID}").submit (event) ->

            do event.preventDefault

            $username = jQuery "##{formID}Username"
            $password = jQuery "##{formID}Password"

            unless $username.val()
                toastr.error "Username can't be empty.", "Auth Failed"
                do $username.focus
                return

            unless $password.val()
                toastr.error "Password can't be empty.", "Auth Failed"
                do $password.focus
                return

            auth $username.val(), $password.val()
            toastr.success "Credentials set to coshGitHubAuth.", "Authorised"

        undefined

The `publish` function from the [API](/docs/gists.md).

    window.publish = (target) ->

        output = undefined

        if target.isString?() then target = get target
        unless target
            toastr.error "Hash not found.", "Publishing Failed"
            return
        unless authData = do authHeader
            toastr.error "Couldn't find credentials.", "Publishing Failed"
            return

        data =
            description: target.description
            public: true
            files: {}
        data.files[target.coshKey] = content: target.content

        jQuery.ajax
            type: "POST"
            data: JSON.stringify data
            async: false
            url: gistEndpoint "/gists"
            headers: authData
            error: (result) ->
                reason = JSON.parse(result.responseText).message
                toastr.error reason, "Publishing failed"
            success: (data) ->
                output = set gist2chit data
                toastr.success output.gistID, "Published Gist"

        output

The `push` function from the [API](/docs/gists.md).

    window.push = (target) ->

        output = undefined

        if target.isString?() then target = get target

        unless target
            toastr.error "Hash not found.", "Push Failed"
            return

        unless target.gistID
            toastr.error "#{target.coshKey} is unpublished.", "Push Failed"
            return

        unless authData = do authHeader
            toastr.error "No credentials.", "Push Failed"
            return

        data = description: target.description, files: {}
        data.files[target.coshKey] =
            filename: target.coshKey
            content: target.content

        jQuery.ajax
            type: "PATCH"
            data: JSON.stringify data
            async: false
            url: gistEndpoint "/gists/#{target.gistID}"
            headers: authData
            error: (result) ->
                reason = JSON.parse(result.responseText).message
                toastr.error reason, "Push Failed"
            success: (data) ->
                output = gist2chit data
                toastr.success target.coshKey, "Pushed Gist"

        output

The `publish` function from the [API](/docs/gists.md).

    window.clone = (gistID) ->

        output = undefined

        jQuery.ajax
            type: "GET"
            async: false
            url: gistEndpoint "/gists/#{gistID}"
            success: (data) -> output = gist2chit data
            error: (data) -> toastr.error "Gist not found.", "Clone Failed"

        output

The `gallery` function from the [API](/docs/publishing.md).

    window.gallery = (gistID) ->

        open "https://gallery-cosh.appspot.com/##{gistID}"
        undefined

The `chit` function from the [API](/docs/files.md).

    window.chit = (args...) ->

        return if undefined in args

        [key, options] = \

            if args.length is 1

                if args[0].isString?()
                    [args[0], {description: "", content: ""}]
                else [args[0].coshKey, args[0]]

            else if args.length is 2

                if args[1].isString?()
                    [args[0], {description: args[1] or "", content: ""}]
                else [args[0], args[1].merge
                    description: args[1].description or ""
                    content: args[1].content or ""
                    ]

            else [args[0], args[2].merge description: args[1]]

        options.merge coshKey: key

The following code pre-loads docs into a cache when the user mouses over a
link to them, assuming the doc hasn't been cached already. This speeds things
up a lot.

    pageCache = {}

    getHref = (event) ->

        target = event.target
        do event.preventDefault

        href = target.href or target.parentNode.href

        if href.startsWith location.origin
            return href = href.slice location.origin.length
        else return href

    $board.on "click", "a", (event) ->
        path = getHref event
        if path.endsWith ".md"
            if file = pageCache[path] then peg.low file, "page"
            else jQuery.get path, (file) ->
                pageCache[path] = file
                peg.low file, "page"
        else open path

    $board.on "mouseover", "a", (event) ->
        path = getHref event
        return if not path.endsWith(".md") or pageCache[path]
        jQuery.get path, (page) -> pageCache[path] = page

## Execution and Exception Handling

This stuff needs refactoring, badly. It's where all the compilation, execution,
source mapping, error handling currently lives. Functions that return jQuery
objects shouldn't have names that start with a dollar either.

    $highlightTrace = (source, lineNumber, charNumber) ->

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

    reportCompilationError = (source, error) ->

        line = error.location.first_line
        column = error.location.first_column
        message = "Caught CoffeeScript #{error.name}: #{error.message}"

        jQuery "<div>"
            .attr "class", "color-operator"
            .append $highlightTrace source, line, column
            .append $traceFooterDiv "invalid input [#{line+1}:#{column+1}]"
            .append $errorMessageDiv message
            .appendTo $board

    $nativeErrorDiv = (trace) -> jQuery \
        """
        <div>
        <span class=error>JavaScriptError in
        <span class=color-operator>#{trace.methodName}</span>
        [#{trace.lineNumber}:#{trace.column}]</span>
        </div>
        """

    $coffeeErrorDiv = (item, map, trace) ->

        $cs = $highlightTrace item.source, map.line-1, map.column
        $js = $highlightTrace item.code, trace.lineNumber-1, trace.column-1

        jQuery "<div>"
            .css "display": "inline"
            .append $cs.attr class: "error-input-cs"
            .append $js.attr class: "error-compiled-js"

    $traceFooterDiv = (origin) ->

        jQuery """
            <div class=trace_footer>
            <span class=trace-counter>#{origin}</span><br><br>
            </div>
            """

    $errorMessageDiv = (message) ->

        jQuery("<xmp>").text(message).addClass "error-message unspaced"

    doMap = (item, trace) ->

        (new smc.SourceMapConsumer do item.map.generate).originalPositionFor
            line: trace.lineNumber
            column: trace.column - 1 or 1

    parseOrigin = (item, map) ->

        locationString = "[#{map.line}:#{map.column + 1}]"

        if item.shell then return "#{item.count} #{locationString}"

        [key, date] = item.count.split "@"

        "#{key} #{locationString} [#{date}]"

    jQuery("#board").on "click", ".error-input-cs, .input-cs", ->

        jQuery(@).next().slideToggle(200).css display: "block"

### Execution

The `cosh.execute` function handles all execution of CoffeeScript code. It
stashes the source maps and other input data on successful compilation. It
also handles CoffeeScript compilation errors. Runtime errors are handled in
`window.onerror` below.

    cosh.execute = (source, url) ->

        shell = if url then false else true
        literate = url?.endsWith(".coffee.md") or url?.endsWith(".litcoffee")

        url += "@#{new Date().format '{dd}:{MM}:{yyyy}:{HH}:{mm}:{ss}'}" if url

        options = bare: true, sourceMap: true, literate: literate

        try code = coffee.compile source, options
        catch error

            reportCompilationError source, error
            slate.updateHistory source if shell
            slate.setValue ""
            return do clock.scrollIntoView

        if shell

            inputCount++
            slate.updateHistory source
            url = "slate#{inputCount}.js"
            jQuery("#slate-count").html inputCount + 1
            slate.setValue ""

        inputs[url] =
            name: url
            code: code.js
            shell: shell
            source: source
            count: if shell then inputCount else url
            map: code.sourceMap

        if shell

            $csSource = jQuery "<xmp>"
                .text source
                .addClass "input-cs"
                .appendTo $board
            $jsSource = jQuery "<xmp>"
                .text code.js
                .addClass "compiled-js"
                .appendTo $board

        try result = eval.call window, "#{code.js}\n//# sourceURL=#{url}"
        catch error

            if error.stack.startsWith "SyntaxError"
                $csSource.css color: "#999"
                $jsSource.css color: "#999"
                error.backtickedCode = true
            else if shell
                do $csSource.remove
                do $jsSource.remove
            throw error

        return unless shell
        put.low result, "unspaced"
        do clock.scrollIntoView

### Exception Handling

This is where runtime errors get caught and stacktaces are generated from data
stashed by the `cosh.execute` function above.

    window.onerror = (message, url, line, column, error) ->

        if error.backtickedCode then message = "Lost #{message}"

        traceDivs = []

        for trace in parseTrace error.stack

            if item = inputs[trace.file]
                map = doMap item, trace
                origin = parseOrigin item, map
                $traceDiv = $coffeeErrorDiv item, map, trace
            else
                origin = trace.file
                $traceDiv = $nativeErrorDiv trace

            $traceDiv.append $traceFooterDiv origin
            traceDivs.push $traceDiv

        $stackDiv = jQuery "<div>"
        $stackDiv.append traceDivs.reverse()
        $stackDiv.append $errorMessageDiv message
        $board.append $stackDiv
        do clock.scrollIntoView

This parses the stacktrace string that `window.onerror` knows as `error.stack`,
converting it into an array of items from the stack, as hashes. It returns an
array of two objects, the stack array it creates, and a bool, truthy if the
stacktrace fails to reach the `limit`, which is essentially this file.
Traces are truncated at the borders of userland.

    parseTrace = (traceback) ->

        stack = []
        lines = traceback.split "\n"

        ignore = (url) -> bool \
            url is "/cosh/main.js" or
            url.startsWith "#{location.origin}/scripts"

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

        stack

    jQuery("#favicon").attr href: "/images/skull_up.png"
    toastr.info(
        "Powered by CoffeeScript (#{coffee.VERSION})"
        "CoffeeShop: The HTML5 Shell"
        timeOut: 1600
        )

## Launch Shell

This is the last bit of code to run on boot.

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
            undefined

        try get "config.coffee"
        catch then set chit

            coshKey: "config.coffee",
            description: "Run on boot unless in safe mode."
            content: 'print "/docs/home.md"'

        safemode = launchCode is "safemode"

        $brand
            .css( color: if safemode then "#D88E5C" else "#93A538" )
            .text( if safemode then "Safe Mode" else "c[_]" )

        edit "config.coffee"

        if launchCode isnt "safemode" then run "config.coffee"

### The End

All done; just focus the slate. The comment at the bottom is a source URL
directive that allows the shell to recognise this file in stacktraces, so
the stack can be filtered correctly.

    do slate.focus

    `//# sourceURL=/cosh/main.js
    `

[1]: https://github.com/chjj/marked
[2]: http://stackoverflow.com/a/8460753/1253428
