# CoffeeShop

This is the main CoffeeShop file. It is loaded, compiled, cached and executed within a
function inside `boot.js`. All of cosh's code, except for `index.html`, `shell.css` and
`boot.js`, lives in this file. This file's dependencies, `coffee`, `marked`, `pprint` and
`smc` (Source Map Consumer), are loaded by `boot.js`.

## Set Up the Namespace

First, just make sure `window.indexedDB` is the correct object or `undefined`. Users may
arrive at the Gallery in any browser, so it's important to have this when nuking the DB.

    window.indexedDB = \
        indexedDB or
        mozIndexedDB or
        webkitIndexedDB or
        msIndexedDB

This code creates a global named `cosh` that internal stuff can be bound to, but still be
available to the user if they need it. If they often do, the API should be extended.
The code also sets up a global function named `uniquePin` that can be used to get an
integer that's always unique. This can be used in element IDs to keep them unique when
rendered multiple times.

    window.cosh =
        uniquePin: 0
        coffeeVersion: coffee.VERSION

    window.uniquePin = -> cosh.uniquePin++

Gallery mode is based on the URL. Port `9090` is supported on localhost for development.

    window.galleryMode = location.host in [
        "gallery-cosh.appspot.com"
        "localhost:9090"
        ]

Set jQuery to not cache ajax requests, and disable the
[Marked parser](https://github.com/chjj/marked)'s `sanitize` option.

    jQuery.ajaxSetup cache: false
    marked.setOptions sanitize: false

This needs changing so the method isn't iterable. The method is documented
[here](/docs/string.compile.md).

    String::compile = (lang, options={}) ->

        if lang in ["cs", "coffee", "coffeescript"]
            options.merge bare: true if options.bare is undefined
            return coffee.compile this, options
        if lang in ["md", "markdown"]
            return marked this, options

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

    $board
    .on "mouseover", -> jQuery("body").css overflow: "scroll"
    .on "mouseout",  -> jQuery("body").css overflow: "hidden"

This is used internally as a more Pythonic thruthiness test.

    bool = (thing) ->

        if thing.equals([]) or thing.equals({}) then false
        else if thing is "false" then true
        else !! thing

## The Output Functions

The `get` method from [the API](/docs/storage.md).

    window.get = (key) ->

        item = localStorage.getItem key
        if item then JSON.parse item

The `set` method from [the API](/docs/storage.md).

    window.set = (args...) ->

        return if undefined in args
        switch args.length
            when 1 then [key, value] = [ args[0].coshKey, args[0] ]
            when 2 then [key, value] = args
            else return toastr.error "Wrong number of args.", "Set Failed"
        unless key
            toastr.error "Bad args.", "Set Failed"
            return
        if remote key
            toastr.error "Key contains illegal characters.", "Set Failed"
            return
        if value.coshKey then value.coshKey = key
        localStorage.setItem key, JSON.stringify value
        editor.updateCurrentFile()

        value

The `pop` method from [the API](/docs/storage.md).

    window.pop = (target) ->

        return toastr.error "Not enough args.", "Pop Failed" unless target
        key = if target.isString?() then target else target.coshKey
        item = get key
        return toastr.error "Nothing at #{target}.", "Pop Failed" unless item
        localStorage.removeItem key
        toastr.success target, "Popped From Local Storage"
        editor.updateStatus()

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

    jQuery('#footer').click -> slate.focus()

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

        slateDiv.style.height = "#{16*doc.getLength()}px"
        slate.resize()
        do clock.scrollIntoView

This makes `pre` tags inside the board clickable, loading their content into the slate when
clicked.

    jQuery("#board").on "click", "pre", (event) ->

        source = event.target.innerText.slice 0, -1
        if slate.getValue() isnt source then slate.push source
        else slate.focus()

This keybinding makes `Meta.Up` rewind the input history.

    slate.commands.addCommand
        name: "rewind_history"
        bindKey: win: "Ctrl-Up", mac: "Cmd-Up"
        exec: ->
            source = slate.getValue()
            if pointer >= 0 and source isnt slate.history[pointer]
                stash = source
                pointer = slate.history.length
            pointer -= 1
            if pointer >= 0
                slate.setValue slate.history[pointer]
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
            source = slate.getValue()
            if pointer isnt -1 and source isnt slate.history[pointer]
                stash = source
                pointer = slate.history.length
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
        exec: -> editor.focus()

This keybinding makes `Meta.Enter` execute the slate content.

    slate.commands.addCommand
        name: "execute_slate"
        bindKey: win: "Ctrl-Enter", mac: "Cmd-Enter"
        exec: ->
            source = slate.getValue()
            source = source.lines (line) -> line.trimRight()
            source = source.join '\n'
            cosh.execute source if source

This keybinding makes `Meta.S` call `editor.set` to set the chit to storage.

    slate.commands.addCommand
        name: "set_editor_chit"
        bindKey: win: "Ctrl-S", mac: "Cmd-S"
        exec: -> editor.set()

This keybinding makes `Meta.P` call `slate.print` to print the slate.

    slate.commands.addCommand
        name: "print_editor"
        bindKey: win: "Ctrl-P", mac: "Cmd-P"
        exec: -> editor.print()

This API function resets the line history. It actually just sets the history store and the
volatile copy to empty arrays.

    slate.reset = -> set historyStore, slate.history = []

This API function pushes a string to the slate, pushing the slate content to the input
history. The push to the input history is actually done by `slate.updateHistory`.

    slate.push = (source) ->

        value = slate.getValue()
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
        exec: -> editor.run()

This keybinding makes `Meta.P` call `editor.print` to print some Markdown.

    editor.commands.addCommand
        name: "print_chit"
        bindKey: win: "Ctrl-P", mac: "Cmd-P"
        exec: -> editor.print()

This keybinding makes `Meta.S` call `editor.set` to set the chit to storage.

    editor.commands.addCommand
        name: "set_chit"
        bindKey: win: "Ctrl-s", mac: "Cmd-s"
        exec: -> editor.set()

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
            slate.focus()
            do clock.scrollIntoView

This keybinding makes `Shift.Tab` move the focus to the description div, but only if no
code is selected, else it indents the code as Ace normally would.

    editor.commands.addCommand
        name: "focus_description"
        bindKey: win: "Shift-Tab", mac: "Shift-Tab"
        exec: ->
            if editor.getCopyText() then editor.blockOutdent()
            else $descriptionDiv.focus()

This API function executes the currently selected text, or the whole content if nothing is
selected, using the cosh key as the file name. It supports Literate CoffeeScript files.

    editor.run = ->

        source = editor.getCopyText() or editor.getValue()
        toastr.info currentFile.coshKey, "Editor Running", timeOut: 1000
        cosh.execute source, currentFile.coshKey

        undefined

This API function renders the currently selected text, or the whole content if nothing is
selected, to the board as Markdown.

    editor.print = ->

        source = editor.getCopyText() or editor.getValue()
        peg.low source.compile "md", "page"

        undefined

This API function opens a chit in the editor. It's available globally too as `edit`.

    editor.edit = (target) ->

        item = if target.isString?() then get target else target
        return toastr.error "Nothing at #{target}.", "Edit File Failed" unless item

        if item.coshKey.endsWith(".md") or item.coshKey.endsWith(".litcoffee")
            mode = "ace/mode/markdown"
        else mode = "ace/mode/coffee"

        currentFile = item
        $nameDiv.text currentFile.coshKey
        $descriptionDiv.text currentFile.description
        editor.session.setMode mode
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
        currentFile.content = editor.getValue()
        set currentFile
        $nameDiv.css color: "#B2D019"
        currentFile

This function is used internally to trigger the editor's checks that allow it to keep the
chit status colour correct.

    editor.updateStatus = ->

        lines = editor.session.getLength() + 1
        $editorLinks.css left: 689 + 7 * lines.toString().length
        test = currentFile?.equals get currentFile.coshKey
        test = test and editor.getValue() is currentFile.content
        test = test and $descriptionDiv.text() is currentFile.description
        $nameDiv.css color: if test then "#B2D019" else "#E18243"

This function and the event handlers that follow it are used internally to update the
`currentFile` using the copy in local storage. It has no effect when the hash isn't
found in local storage.

    editor.updateCurrentFile = ->

        update = get currentFile.coshKey
        currentFile = update if update
        editor.updateStatus()

    editor.on "change", editor.updateStatus
    $descriptionDiv.on "input", editor.updateStatus

This event handler is bound to the description div, and gives it all it's keybindings.

    $descriptionDiv.bind "keydown", (event) ->

        if event.which is 9 or event.which is 13
            editor.focus()
            event.preventDefault()
            return

        return if not (event.ctrlKey or event.metaKey)

        if event.which is 190
            slate.focus()
            event.preventDefault()
            return

        if String.fromCharCode(event.which).toLowerCase() is 's'
            event.preventDefault()
            editor.set()

## The Shell API

The `editor.edit` method is also a global, `edit`, and is part of the shell API.

    window.edit = editor.edit

This function is used internally to decide whether a string is a URL or storage key.

    remote = (path) -> "/" in path

The `run` method from [the API](/docs/files.md).

    window.run = (target) ->

        if target.isString()
            path = target
            if remote target then content = load target
            else content = get(target)?.content
        else
            path = target.coshKey
            content = target.content

        if path and content?
            toastr.info path, "Running Chit", timeOut: 1000
            cosh.execute content, path
        else toastr.error "No file hash at #{target}.", "Run Failed"

        undefined

The `put` method from [the API](/docs/output.md).

    window.put = (args...) ->

        text = bool $board.text()
        output = put.low args...
        output.addClass "unspaced" if text

        undefined

    put.low = (args...) ->

        arg = args[0]
        kind = "color-object"

        if arg is null then arg = "null"
        else if arg is undefined then return do clock.scrollIntoView
        else if arg.isDate?() then arg = arg.format()
        else if arg.isString?()
            if arg then kind = "color-string" else arg = "empty string"
        else
            try arg = pprint.parse(arg)
            catch error then arg = arg.toString()

        peg.low jQuery("<xmp>"), args[1]
        .addClass kind
        .html arg

The `peg` method from [the API](/docs/output.md).

    window.peg = (args...) ->

        text = bool $board.text()
        output = peg.low args...
        output.addClass "unspaced" if text

        undefined

    peg.low = (tree, options) ->

        if tree instanceof jQuery then $tree = tree
        else if tree instanceof HTMLElement then $tree = jQuery tree
        else if tree.isString?() then $tree = jQuery("<div>").html tree.compile "md"
        else $tree = jQuery("<xmp>").html tree.toString()

        if options isnt undefined
            if options.isString?() then $tree.first().addClass options
            else $tree = options $tree

        $board.append $tree

        if $tree[0].className is "page"
            jQuery("html")
            .animate { scrollTop: $tree.offset().top - 27 }, duration: 150
        else do clock.scrollIntoView

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
            async: if callback then true else false
            success: (response) ->
                if callback then callback response
                else output = response

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

        return unless authData = auth()
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

        formID = "coshID#{uniquePin()}"

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

            event.preventDefault()

            $username = jQuery "##{formID}Username"
            $password = jQuery "##{formID}Password"

            unless $username.val()
                toastr.error "Username can't be empty.", "Auth Failed"
                return $username.focus()
            unless $password.val()
                toastr.error "Password can't be empty.", "Auth Failed"
                return $password.focus()

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
        unless authData = authHeader()
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
        unless authData = authHeader()
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

    window.chit = (args...) ->

        return if undefined in args

        switch args.length
            when 3
                [key, description, options] = args
                options.description = description
            when 2
                [key, lastArg] = args
                if lastArg.isString?()
                    options =
                        description: lastArg or ""
                        content: ""
                else
                    options = lastArg
                    options.description = options.description or ""
                    options.content = options.content or ""
            when 1
                if args[0].isString?()
                    options = description: "", content: ""
                    key = args[0]
                else
                    options = args[0]
                    key = options.coshKey
            else
                toastr.error "Invalid arguments.", "Chit Creation Failed"
                return

        options.coshKey = key
        options

The following code pre-loads docs into a cache when the user mouses over a link to them,
assuming the doc hasn't been cached already. This speeds things up a lot.

    pageCache = {}

    getHref = (event) ->

        target = event.target
        event.preventDefault()
        href = target.href or target.parentNode.href
        if href.startsWith location.origin
            href = href.slice(location.origin.length)

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

### Execution

The `cosh.execute` function handles all execution of CoffeeScript code. It stashes the
source maps and other input data on successful compilation. It also handles CoffeeScript
compilation errors. Runtime errors are handled in `window.onerror` below.

    cosh.execute = (source, url) ->

        shell = if url then false else true
        literate = url?.endsWith(".coffee.md") or url?.endsWith(".litcoffee")
        url += "@#{+(new Date())}" if url
        options = bare: true, sourceMap: true, literate: literate

        try code = coffee.compile source, options
        catch error

            line = error.location.first_line
            column = error.location.first_column
            message = "Caught CoffeeScript #{error.name}: #{error.message}"

            $board.append(
                jQuery "<div>"
                .attr "class", "color-operator"
                .append highlightTrace source, line, column
                .append jQuery("<xmp>").text message
                )

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

            $source = jQuery("<xmp>").html(source).css color: "#4DBDBD"
            $board.append $source

        try result = eval.call window, "#{code.js}\n//# sourceURL=#{url}"
        catch error
            $source?.remove()
            throw error

        put.low result, "unspaced" if shell
        do clock.scrollIntoView

### Exception Handling

This is where runtime errors get caught and stacktaces are generated from data stashed by
the `cosh.execute` function above.

    window.onerror = (message, url, line, column, error) ->

        traceDivs = []
        [stack, untraceable] = parseTrace error.stack
        if untraceable then message = "Untraceable #{message}"

        for trace in stack

            if item = inputs[trace.file]

                map = new smc.SourceMapConsumer item.map.generate()
                .originalPositionFor
                    line: trace.lineNumber
                    column: trace.column - 1 or 1

                locationString = "[#{map.line}:#{map.column + 1}]"

                if item.shell then origin = "#{item.count} #{locationString}"
                else
                    [key, date] = item.count.split "@"
                    date = new Date(+date).toString().split(" GMT")[0]
                    origin = "#{key} #{locationString} [#{date}]"

                $traceDiv = jQuery "<div>"
                .css "display": "inline"
                .append highlightTrace item.source, map.line - 1, map.column

            else

                origin = trace.file
                $traceDiv = jQuery """
                    <div>
                    <span class=error>JavaScriptError in
                    <span class=color-operator>#{trace.methodName}</span>
                    [#{trace.lineNumber}:#{trace.column}]</span>
                    </div>
                    """

            $countDiv = jQuery "<div class=trace_footer>"
            .html "<span class=trace-counter>#{origin}</span><br><br>"
            $traceDiv.append $countDiv
            traceDivs.push $traceDiv

        $stackDiv = jQuery "<div>"
        loop
            $stackDiv.append traceDivs.pop()
            break unless traceDivs.length

        $messageDiv = jQuery "<xmp>"
        .text message
        .attr class: "error-message unspaced"
        $stackDiv.append $messageDiv
        $board.append $stackDiv
        do clock.scrollIntoView

This highlights the source code for single item in a stacktrace, escaping the code and
colouring it, before converting it into the jQuery object that the function returns.

    highlightTrace = (source, lineNumber, charNumber) ->

        escape = (line) -> line.escapeHTML().split(' ').join "&nbsp;"

        lines = source.lines()
        line  = lines[lineNumber]

        start = escape line.slice 0, charNumber
        end   = escape line.slice charNumber + 1

        char = line[charNumber]
        look = if char then "color-operator" else "error-missing-char"
        char = if char then escape char else "&nbsp;"

        lines[lineNumber] = "#{start}<span class=#{look}>#{char}</span>#{end}"

        for line, index in lines
            if index isnt lineNumber then lines[index] = escape line

        jQuery("<span class=error>").html lines.join "<br>"

This parses the stacktrace string that `window.onerror` knows as `error.stack`, converting
it into an array of items from the stack, as hashes. It returns an array of two objects,
the stack array it creates, and a bool, truthy if the stacktrace fails to reach the
`limit`, which is essentially this file. Traces are truncated at the borders of userland.

    parseTrace = (traceback) ->

        stack = []
        lines = traceback.split "\n"
        limit = "/cosh/main.js;"

        gecko = /^(?:\s*(\S*)(?:\((.*?)\))?@)?((?:file|http|https).*?):(\d+)(?::(\d+))?\s*$/i
        node = /^\s*at (?:((?:\[object object\])?\S+(?: \[as \S+\])?) )?\(?(.*?):(\d+)(?::(\d+))?\)?\s*$/i
        chrome = /^\s*at (?:(?:(?:Anonymous function)?|((?:\[object object\])?\S+(?: \[as \S+\])?)) )?\(?((?:file|http|https):.*?):(\d+)(?::(\d+))?\)?\s*$/i

        for line in lines

            if parts = chrome.exec line

                return [stack, false] if parts[2] is limit

                element =
                    file: parts[2]
                    methodName: parts[1] or "<unknown>"
                    lineNumber: +parts[3]
                    column: (if parts[4] then +parts[4] else null)

            else if parts = node.exec line

                return [stack, false] if parts[2] is  limit

                element =
                    file: parts[2]
                    methodName: parts[1] or "<unknown>"
                    lineNumber: +parts[3]
                    column: (if parts[4] then +parts[4] else null)

            else if parts = gecko.exec line

                return [stack, false] if parts[3] is limit

                element =
                    file: parts[3]
                    methodName: parts[1] or "<unknown>"
                    lineNumber: +parts[4]
                    column: (if parts[5] then +parts[5] else null)

            else continue
            stack.push element

        [stack, true]


    jQuery("#favicon").attr href: "/images/skull_up.png"
    toastr.info "Powered by CoffeeScript (#{coffee.VERSION})", "CoffeeShop: The HTML5 Shell"

### Gallery Mode

If the shell is in gallery mode, then storage needs nuking. This is done now and again on
unload so that if the `onunload` function gets edited, nothing will persist beyond the next
boot, making it pointless to hack `onunload`.

Then the gist specified in the launch code is cloned ~ a fallback gist used if a valid gist
id is not provided. The gist is then loaded into the editor and run.

    if galleryMode

        do window.onunload = ->
            localStorage?.clear()
            sessionStorage?.clear()
            indexedDB?.deleteDatabase "*"

        fallback = "9419b50cdaa7238725d8"
        window.mainFile = clone(launchCode or fallback) or clone(fallback)
        edit set mainFile
        editor.run()

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

    slate.focus()

    `//# sourceURL=/cosh/main.js`
