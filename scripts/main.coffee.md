# CoffeeShop

This is the main CoffeeShop file. It is loaded, compiled, cached and executed within a
function inside `boot.js`. All of cosh's code, except for `index.html`, `shell.css` and
`boot.js`, lives in this file. This file's dependencies, `coffee`, `marked`, `pprint` and
`smc` (Source Map Consumer), are loaded by `boot.js`.

## Set Up the Namespace

First, just make sure `window.indexedDB` is the correct object or `undefined`. Users may
arrive at the Gallery in any browser, so it's important to have this when nuking the DB.

    window.indexedDB = indexedDB or mozIndexedDB or webkitIndexedDB or msIndexedDB

This code creates a global named `cosh` that internal stuff can be bound to, but still be
available to the user if they need it. If they often do, the API should be extended. The
code also sets up the globals `uniquePIN` and `uniqueID`.

    window.cosh = uniquePIN: 0, coffeeVersion: coffee.VERSION

    window.uniquePIN = -> cosh.uniquePIN++

    window.uniqueID = -> "coshID" + do uniquePIN

Gallery mode is based on the URL. Port `9090` is supported on localhost for development.

    window.galleryMode = location.host in [
        "gallery-cosh.appspot.com"
        "localhost:9090"
        ]

Set jQuery to not cache ajax requests, and disable the
[Marked parser](https://github.com/chjj/marked)'s `sanitize` option.

    jQuery.ajaxSetup cache: no
    marked.setOptions sanitize: no

This needs changing so the method isn't iterable. The method is documented
[here](/docs/string.compile.md).

    String::compile = (lang, options={}) ->

        if lang in ["cs", "coffee", "coffeescript"]
            options.merge bare: true if options.bare is undefined
            try return coffee.compile this, options
            catch error then return error
            return false
        if lang in ["md", "markdown"] then return marked this, options

These are all local variables pointing to elements, most wrapped by jQuery.

    $brand = jQuery "#brand"
    $slate = jQuery "#slate"
    $clock = jQuery "#clock"
    $board = jQuery "#board"
    $nameDiv = jQuery "#filename"
    $editorLinks = jQuery "#editor-links"
    $descriptionDiv = jQuery "#file-description"

    clock = document.getElementById "clock"
    slateDiv = document.getElementById "slate"

These are the links above the board.

    jQuery("#home-link").click -> print "/docs/home.md"
    jQuery("#more-link").click -> print "/docs/external.md"
    jQuery("#book-link").click -> print "/docs/front.md"

This is a simple webworker that updates the time on the clock in the footer.

    worker = new Worker "/scripts/cosh/clock_worker.js"
    worker.onmessage = (event) -> $clock.text event.data

The board should only scroll if the mouse is over it...

    $board
        .on "mouseover", -> jQuery("body").css overflow: "scroll"
        .on "mouseout",  -> jQuery("body").css overflow: "hidden"

This is used internally for sane truthiness tests.

    bool = (thing) ->

        if thing in [undefined, null, NaN] then false
        else if thing.equals([]) or thing.equals({}) then false
        else if thing is "false" then true
        else !! thing

The rest of the HTML escape function.

    escape = (line) ->

        line.escapeHTML()
            .split(" ").join  "&nbsp;"
            .split("\n").join "<br>"
            .split("\t").join "&nbsp;&nbsp;&nbsp;&nbsp;"

## The Output Functions

The `get` method from [the API](/docs/storage.md).

    window.get = (key) -> if item = localStorage.getItem key then JSON.parse item

The `set` method from [the API](/docs/storage.md).

    window.set = (args...) ->

        return if undefined in args

        reserved = (key) -> bool key.each /[*/!@:+(){}|$]/

        switch args.length
            when 2 then [key, value] = args
            when 1 then [key, value] = [args[0].coshKey, args[0]]
            else return toastr.error "Wrong number of args.", "Set Failed"
        return toastr.error "Bad args.", "Set Failed" unless key
        return toastr.error "Invalid key.", "Set Failed" if reserved key

        value.coshKey = key if value.coshKey

        localStorage.setItem key, JSON.stringify value
        do editor.updateCurrentFile
        value

The `pop` method from [the API](/docs/storage.md).

    window.pop = (target) ->

        return toastr.error "Not enough args.", "Pop Failed" unless target
        key = if target.isString?() then target else target.coshKey
        return toastr.error "Nothing at #{target}.", "Pop Failed" unless item = get key
        localStorage.removeItem key
        do editor.updateStatus
        item

## The Slate

This is a bunch of locals used by the slate, which manages the input history too. Clicking
the footer focusses the slate to make it easier to click into when it's small.

    inputs = {}
    inputCount = 0
    window.slate = ace.edit "slate"
    historyStore = "coshHistoryStore"
    slate.history = get(historyStore) or []
    pointer = slate.history.length
    stash = ""

    jQuery('#footer').click -> do slate.focus

Configure the slate, an instance of Ace.

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
    doc = slate.getSession().getDocument()

This, using `doc`, resizes the slate on change.

    slate.on "change", ->

        slateDiv.style.height = "#{ 16 * do doc.getLength }px"
        do slate.resize
        do clock.scrollIntoView

This makes `pre` tags inside the board clickable, loading their content into the slate
when clicked.

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
            if pointer < slate.history.length then slate.setValue slate.history[pointer]
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
            source = ( slate.getValue().lines (line) -> do line.trimRight ).join "\n"
            cosh.execute source if source

This keybinding makes `Meta.S` call `editor.set` to set the chit to storage.

    slate.commands.addCommand
        name: "set_editor_chit"
        bindKey: win: "Ctrl-S", mac: "Cmd-S"
        exec: -> do editor.set

This keybinding makes `Meta.P` call `slate.print` to print the slate.

    slate.commands.addCommand
        name: "print_editor"
        bindKey: win: "Ctrl-P", mac: "Cmd-P"
        exec: -> do editor.print

This API function resets the line history. It actually just sets the history store and the
volatile copy to empty arrays.

    slate.reset = -> set historyStore, slate.history = []

This API function pushes a string to the slate, pushing the slate content to the input
history. The push to the input history is actually done by `slate.updateHistory`.

    slate.push = (source) ->

        value = do slate.getValue
        slate.updateHistory value if value
        slate.setValue source
        slate.clearSelection 1
        slate.focus()
        value

This API function is used to push inputs to the input history internally. It does some
housekeeping to remove any older duplicate.

    slate.updateHistory = (source) ->

        index = slate.history.indexOf source
        slate.history.splice(index, 1) if index isnt -1
        pointer = slate.history.push source

## The Editor

The editor is another instance of slate with a few extras for ensuring the hash status
colour reflects whether or not the hash is different in local storage and executing the
content.

    currentFile = {}
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

This keybinding makes `Meta.Enter` call `editor.run` to execute some code.

    editor.commands.addCommand
        name: "execute_editor"
        bindKey: win: "Ctrl-Enter", mac: "Cmd-Enter"
        exec: -> do editor.run

This keybinding makes `Meta.P` call `editor.print` to print some Markdown.

    editor.commands.addCommand
        name: "print_chit"
        bindKey: win: "Ctrl-P", mac: "Cmd-P"
        exec: -> do editor.print

This keybinding makes `Meta.S` call `editor.set` to set the chit to storage.

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

This keybinding makes `Shift.Tab` move the focus to the description div, but only if no
code is selected, else it indents the code as Ace normally would.

    editor.commands.addCommand
        name: "focus_description"
        bindKey: win: "Shift-Tab", mac: "Shift-Tab"
        exec: ->
            if editor.getCopyText() then editor.blockOutdent()
            else do $descriptionDiv.focus

This API function executes the currently selected text, or the whole content if nothing is
selected, using the cosh key as the file name. It supports Literate CoffeeScript files.

    editor.run = ->

        source = editor.getCopyText() or editor.getValue()
        source = ( source.lines (line) -> do line.trimRight ).join "\n"
        toastr.info currentFile.coshKey, "Editor Running", timeOut: 1000
        cosh.execute source, currentFile.coshKey
        do clock.scrollIntoView

This API function renders the currently selected text, or the whole content if nothing is
selected, to the board as Markdown.

    editor.print = ->

        source = editor.getCopyText() or editor.getValue()
        peg.low source, "page"
        undefined

This API function opens a chit in the editor. It's available globally too as `edit`.

    editor.edit = (target) ->

        item = if target.isString?() then get target else target
        return toastr.error "Nothing at #{target}.", "Edit File Failed" unless item

        md = item.coshKey.endsWith(".md") or item.coshKey.endsWith(".litcoffee")

        currentFile = item
        $nameDiv.text currentFile.coshKey
        $descriptionDiv.text currentFile.description
        editor.session.setMode "ace/mode/#{ if md then 'markdown' else 'coffee' }"
        editor.setValue currentFile.content
        editor.updateStatus()
        editor.clearSelection 1
        editor.gotoLine 1
        editor.getSession().setScrollTop 1
        editor.focus()
        undefined

This API function sets the current chit, `currentFile`, to local storage.

    editor.set = ->

        currentFile.description = $descriptionDiv.text() or "?"
        currentFile.content = do editor.getValue
        set currentFile
        $nameDiv.css color: "#B2D019"
        currentFile

This function is used internally to trigger the editor's checks that allow it to keep the
chit status colour correct.

    editor.updateStatus = ->

        lines = editor.session.getLength() + 1
        $editorLinks.css left: 689 + 7 * lines.toString().length

        inSync =
            ( currentFile?.equals get currentFile.coshKey )   and
            ( editor.getValue() is currentFile.content )      and
            ( $descriptionDiv.text() is currentFile.description )

        $nameDiv.css color: if inSync then "#B2D019" else "#E18243"

This function and the event handlers that follow it are used internally to update the
`currentFile` using the copy in local storage. It has no effect when the hash isn't
found in local storage.

    editor.updateCurrentFile = ->

        if update = get currentFile.coshKey then currentFile = update
        do editor.updateStatus

    editor.on "change", editor.updateStatus
    $descriptionDiv.on "input", editor.updateStatus

This event handler is bound to the description div, and gives it all it's keybindings.

    $descriptionDiv.bind "keydown", (event) ->

        if event.which is 9 or event.which is 13
            do editor.focus
            do event.preventDefault
            return

        return if not (event.ctrlKey or event.metaKey)

        if event.which is 190
            do event.preventDefault
            do slate.focus
            return

        if String.fromCharCode(event.which).toLowerCase() is 's'
            do event.preventDefault
            do editor.set

## The Shell API

The `editor.edit` method is also a global, `edit`, and is part of the shell API.

    window.edit = editor.edit

This function is used internally to decide whether a string is a URL or not.

    remote = (path) -> "/" in path

The `run` method from [the API](/docs/files.md).

    window.run = (target) ->

        [path, content] =
            if not target.isString() then [target.coshKey, target.content]
            else [target, if remote target then load target else get(target)?.content]

        if path and content?
            toastr.info path, "Running Chit", timeOut: 1000
            cosh.execute content, path
        else toastr.error "No file hash at #{target}.", "Run Failed"

        undefined

The `put` method from [the API](/docs/output.md).

    window.put = (args...) ->

        boardWasNotEmpty = bool $board.text()
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

        $tree = \

            if tree instanceof jQuery then tree
            else if tree instanceof HTMLElement then jQuery tree
            else if tree?.isString?() then jQuery("<div>").html tree.compile "md"
            else jQuery("<xmp>").html tree?.toString() or jQuery "<div>"

        if options isnt undefined

            if options.isString?() then $tree.addClass options
            else if options.isFunction?() then $tree = options $tree
            else

                $tree = options.func $tree    if options.func
                $tree.attr id: options.id     if options.id
                $tree.addClass options.class  if options.class

        $board.append $tree

        if $tree[0].className isnt "page" then do clock.scrollIntoView
        else jQuery("html").animate { scrollTop: $tree.offset().top - 27 }, duration: 150

        $tree.children("h1").each ->

            tail = ":".repeat 87 - this.innerText.length
            this.innerHTML += "<span class=color-operator> #{tail}</span>"

        $tree

The `load` method was an API method, and is no more. It's still used internally to make
blocking requests for remote resources.

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

The `clear` method from [the API](/docs/output.md).

    window.clear = -> $board.html("").shush

## The GitHub Gist API

This section extends the shell API to work with gists. It starts by just defining a couple
of helpful locals.

    authStore = "coshGitHubAuth"
    gistEndpoint = (path) -> "https://api.github.com#{path}"

This function can be called with no arguments and it'll attempt to return the GitHub
credentials for the browser, else `null`. I can be called with two arguments, a username
and password, and it'll save them to local storage.

    auth = (args...) ->

        if args.length is 0
            authHash = get(authStore) or sessionStorage.getItem(authStore)
            if authHash?.isString() then JSON.parse authHash else authHash
        else set authStore, { username: args[0], password: args[1] }

This function is called to create a basic auth header string. It'll return `null` if no
credentials are found.

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

This makes the auth banner link load the form defined here and binds a couple of handlers
to it.

    jQuery("#auth-link").click ->

        formID = do uniqueID

        peg.low """
            # GitHub Auth
            To publish or push to gists from cosh, you'll need to provide
            your GitHub username and password.

            ## Authorise This Browser
            You credentials must be locally set to `coshGitHubAuth`. You
            can do it by hand, or use the form provided here.

                set "coshGitHubAuth", { username: "bob", password: "foo" }

            <form id=#{formID}>
            <input id=#{formID}Username type=text placeholder=username>
            <input id=#{formID}Password type=password placeholder=password>
            <input type=submit value="set coshGitHubAuth">
            </form>

            ## Deauthorise This Browser
            You can deauthorise this browser by removing your credentials
            from local storage. The following command would work, or just
            click the pop button.

                pop "coshGitHubAuth"

            <button id=#{formID}Delete>pop coshGitHubAuth</button>
            """

        jQuery("##{formID}Delete").click -> pop authStore

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

    window.publish = (target, published=true) ->

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
            public: published
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
                output = gist2chit data
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

                if args[0].isString?() then [args[0], {description: "", content: ""}]
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

The following code pre-loads docs into a cache when the user mouses over a link to them,
assuming the doc hasn't been cached already. This speeds things up a lot.

    pageCache = {}

    getHref = (event) ->

        target = event.target
        do event.preventDefault
        href = target.href or target.parentNode.href
        href = href.slice location.origin.length if href.startsWith location.origin
        href

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

This stuff needs refactoring. It's where all the compilation, execution, source mapping,
error handling currently lives.

    $highlightTrace = (source, lineNumber, charNumber) ->

        lines = do source.lines
        line  = lines[lineNumber]
        start = escape line.slice 0, charNumber
        end   = escape line.slice charNumber + 1
        char  = line[charNumber]
        look  = if char then "color-operator" else "error-missing-char"
        char  = if char then escape char else "&nbsp;"

        lines[lineNumber] = "#{start}<span class=#{look}>#{char}</span>#{end}"

        for line, index in lines then lines[index] = escape line if index isnt lineNumber

        jQuery("<span class=error>").html lines.join "<br>"

    reportCompilationError = (source, error) ->

        line = error.location.first_line
        column = error.location.first_column
        message = "Caught CoffeeScript #{error.name}: #{error.message}"

        jQuery "<div>"
            .attr "class", "color-operator"
            .append $highlightTrace source, line, column
            .append $traceFooterDiv "invalid input [#{line}:#{column}]"
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

    $coffeeErrorDiv = (item, map) ->

        jQuery "<div>"
            .css "display": "inline"
            .append $highlightTrace item.source, map.line - 1, map.column


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

### Execution

The `cosh.execute` function handles all execution of CoffeeScript code. It stashes the
source maps and other input data on successful compilation. It also handles CoffeeScript
compilation errors. Runtime errors are handled in `window.onerror` below.

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

            $source = jQuery("<xmp>").text(source).css color: "#4DBDBD"
            $board.append $source

        try result = eval.call window, "#{code.js}\n//# sourceURL=#{url}"
        catch error

            if error.stack.startsWith "SyntaxError"
                $source.css color: "#999"
                error.backtickedCode = true
            else if shell then do $source.remove
            throw error

        return unless shell
        put.low result, "unspaced"
        do clock.scrollIntoView

### Exception Handling

This is where runtime errors get caught and stacktaces are generated from data stashed by
the `cosh.execute` function above.

    window.onerror = (message, url, line, column, error) ->

        if error.backtickedCode then message = "Lost #{message}"

        traceDivs = []

        for trace in parseTrace error.stack

            if item = inputs[trace.file]
                map = doMap item, trace
                origin = parseOrigin item, map
                $traceDiv = $coffeeErrorDiv item, map
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
        console.log error

This parses the stacktrace string that `window.onerror` knows as `error.stack`, converting
it into an array of items from the stack, as hashes. It returns an array of two objects,
the stack array it creates, and a bool, truthy if the stacktrace fails to reach the
`limit`, which is essentially this file. Traces are truncated at the borders of userland.

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
                    file: parts[2]
                    methodName: parts[1] or "<unknown>"
                    lineNumber: +parts[3]
                    column: (if parts[4] then +parts[4] else null)

            else if parts = node.exec line

                continue if ignore parts[2]

                element =
                    file: parts[2]
                    methodName: parts[1] or "<unknown>"
                    lineNumber: +parts[3]
                    column: (if parts[4] then +parts[4] else null)

            else if parts = gecko.exec line

                continue if ignore parts[3]

                element =
                    file: parts[3]
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

## Cascading Coffee Scripts

This is the `CCS` function. It is currently undocumented. The `CCS` function is written
to be used outside of cosh, but functions bound to it don't need to be.

    window.CCS = (args...) ->

        anArray = (obj) -> obj instanceof Array

        aRealm = (obj) -> !!(obj and obj.constructor and obj.call and obj.apply)

        aNumber = (obj) -> (not anArray obj) and obj - parseFloat(obj) + 1 >= 0

        aString = (obj) -> typeof obj is "string" or obj instanceof String

        conquer = (realm) -> realm.apply CCS

        hyphenate = (key) ->

            if key is "font" then "font-family"
            else key.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase()

        toHash = (realm) ->

            output = {}
            for key, value of conquer realm then output[hyphenate key] =
                if aRealm value then toHash value
                else if value is 0 then "0"
                else if aNumber value then "#{value}px"
                else if aString value then value
                else "none"
            output

        toCSS = (realm) ->

            output = ""
            for key, value of conquer realm then output +=
                if aRealm value then "\n#{hyphenate key} {#{toCSS value}\n}"
                else if value is 0 then "\n#{hyphenate key}: #{value};"
                else if aNumber value then "\n#{hyphenate key}: #{value}px;"
                else if aString value then "\n#{hyphenate key}: #{value};"
                else "\n#{hyphenate key}: none;"
            output

        [realm, outputType] = \
            if args.length is 1 then [args[0].apply(CCS), "css"]
            else [args[1].apply(CCS), args[0].toLowerCase()]

        if outputType is "map"

            output = {}
            output[key] = toHash realm[key] for key of realm
            return output

        output = ""
        output += "\n#{key} { #{toCSS realm[key]} \n}\n" for key of realm
        output

## Launch Shell

This is the last bit of code to run on boot.

### Gallery Mode

If the shell is in gallery mode, then storage needs nuking. This is done now and again on
unload so that if the `onunload` function gets edited, nothing will persist beyond the next
boot, making it pointless to hack `onunload`.

Then the gist specified in the launch code is cloned ~ a fallback gist used if a valid gist
id is not provided. The gist is then loaded into the editor and run.

    if galleryMode

        do window.onunload = ->
            do localStorage?.clear
            do sessionStorage?.clear
            indexedDB?.deleteDatabase "*"

        fallback = "9419b50cdaa7238725d8"
        window.mainFile = clone(launchCode or fallback) or clone(fallback)
        edit set mainFile
        do editor.run

        $brand.text("CoffeeShop Gallery").css color: "#E18243"

### Shell Mode

If the shell is not in gallery mode, then it needs to check that `config.coffee` exists,
and create it otherwise. It'll then open the config file in the editor and execute it. If
the launch code `safemode` is used, the config is loaded into the editor, but not run.

The `onunload` function is also set up to write the input history to local storage when
the page is destroyed.

    if not galleryMode

        window.onunload = ->
            set historyStore, slate.history.last 400
            undefined

        unless get "config.coffee" then set chit "config.coffee",
            description: "Run on boot unless in safe mode."
            content: 'print "/docs/home.md"'

        $brand.css color: "#E18243"
            .text if launchCode is "safemode" then "Safe Mode" else "CoffeeShop"

        edit "config.coffee"
        if launchCode isnt "safemode"
            cosh.execute get("config.coffee").content, "config.coffee"

### The End

All done. The odd looking comment at the bottom is a source URL directive that allows the
shell to recognise this file in stacktraces, so the stack can be truncated correctly.

    do slate.focus

    `//# sourceURL=/cosh/main.js
    `
