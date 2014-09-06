# main cosh script

window.indexedDB = \
    indexedDB or
    mozIndexedDB or
    webkitIndexedDB or
    msIndexedDB

window.cosh =
    uniquePin: 0
    coffeeVersion: coffee.VERSION

window.uniquePin = -> cosh.uniquePin++

window.galleryMode = location.host in [
    "gallery-cosh.appspot.com"
    "localhost:9090"
    ]

marked.setOptions sanitize: false

String::compile = (lang, options={}) ->

    if lang in ["cs", "coffee", "coffeescript"]
        options.merge bare: true if options.bare is undefined
        return coffee.compile this, options
    if lang in ["md", "markdown"]
        return marked this, options

$brand = jQuery "#brand"
$slate = jQuery "#slate"
$clock = jQuery "#clock"
$board = jQuery "#board"
$nameDiv = jQuery "#filename"
$editorLinks = jQuery "#editor-links"
$descriptionDiv = jQuery "#file_description"
clock = document.getElementById "clock"
slate_div = document.getElementById "slate"

window.get = (key) ->

    item = localStorage.getItem key
    if item then JSON.parse item

window.set = (args...) ->

    return if undefined in args
    switch args.length
        when 1 then [key, value] = [ args[0].coshKey, args[0] ]
        when 2 then [key, value] = args
        else return toastr.error "Wrong number of args.", "Cosh API"
    unless key
        toastr.error "Set failed, bad args.", "Cosh API"
        return
    if value.coshKey then value.coshKey = key
    localStorage.setItem key, JSON.stringify value
    editor.updateCurrentFile()

    value

window.pop = (target) ->

    return toastr.error "Not enough args.", "Cosh API" unless target
    key = if target.isString?() then target else target.coshKey
    item = get key
    return toastr.error "Nothing at #{target}.", "Cosh API" unless item
    localStorage.removeItem key
    toastr.success "Popped #{target}", "Cosh API"
    editor.updateStatus()

    item

inputs = {}
inputCount = 0
window.slate = ace.edit "slate"
historyStore = "coshHistoryStore"
slate.history = get(historyStore) or []
pointer = slate.history.length
stash = ""

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

slate.on "change", ->

    slate_div.style.height = "#{16*doc.getLength()}px"
    slate.resize()
    clock.scrollIntoView()

jQuery("#board").on "click", "pre", (event) ->

    source = event.target.innerText.slice 0, -1
    if slate.getValue() isnt source then slate.push source
    else slate.focus()

slate.reset = -> set historyStore, slate.history = []

slate.push = (source) ->

    value = slate.getValue()
    slate.updateHistory value if value
    slate.setValue source
    slate.clearSelection 1
    slate.focus()
    value

slate.updateHistory = (source) ->

    index = slate.history.indexOf source
    slate.history.splice(index, 1) if index isnt -1
    pointer = slate.history.push source

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
        clock.scrollIntoView()

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
        clock.scrollIntoView()

slate.commands.addCommand
    name: "clear_board"
    bindKey: win: "Ctrl-Esc", mac: "Cmd-Esc"
    exec: -> board.innerHTML = ""

slate.commands.addCommand
    name: "focus_editor"
    bindKey: win: "Ctrl-.", mac: "Cmd-."
    exec: -> editor.focus()

slate.commands.addCommand
    name: "execute_slate"
    bindKey: win: "Ctrl-Enter", mac: "Cmd-Enter"
    exec: ->
        source = slate.getValue()
        source = source.lines (line) -> line.trimRight()
        source = source.join '\n'
        cosh.execute source if source

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

editor.commands.addCommand
    name: "execute_editor"
    bindKey: win: "Ctrl-Enter", mac: "Cmd-Enter"
    exec: -> editor.run()

editor.commands.addCommand
    name: "render_page"
    bindKey: win: "Ctrl-M", mac: "Cmd-M"
    exec: -> editor.render()

editor.commands.addCommand
    name: "set_chit"
    bindKey: win: "Ctrl-s", mac: "Cmd-s"
    exec: -> editor.set()

editor.commands.addCommand
    name: "focus_slate"
    bindKey: win: "Ctrl-.", mac: "Cmd-."
    exec: ->
        slate.focus()
        document.getElementById("clock").scrollIntoView()

editor.commands.addCommand
    name: "focus_description"
    bindKey: win: "Shift-Tab", mac: "Shift-Tab"
    exec: ->
        if editor.getCopyText() then editor.blockOutdent()
        else $descriptionDiv.focus()

editor.run = ->

    source = editor.getCopyText() or editor.getValue()
    cosh.execute source, currentFile.coshKey

editor.render = ->

    source = editor.getCopyText() or editor.getValue()
    append source.compile "md"

editor.edit = (target) ->

    item = if target.isString?() then get target else target
    return toastr.error "Nothing at #{target}.", "Cosh API" unless item

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
    return

editor.set = ->

    currentFile.description = $descriptionDiv.text() or "?"
    currentFile.content = editor.getValue()
    set currentFile
    $nameDiv.css color: "#B2D019"
    currentFile

editor.updateStatus = ->

    lines = editor.session.getLength() + 1
    $editorLinks.css left: 689 + 7 * lines.toString().length
    test = currentFile?.equals get currentFile.coshKey
    test = test and editor.getValue() is currentFile.content
    test = test and $descriptionDiv.text() is currentFile.description
    $nameDiv.css color: if test then "#B2D019" else "#E18243"

editor.updateCurrentFile = ->

    update = get currentFile.coshKey
    currentFile = update if update
    editor.updateStatus()

editor.on "change", editor.updateStatus
$descriptionDiv.on "input", editor.updateStatus

$descriptionDiv.bind "keydown", (event) ->

    if event.which is 9 or event.which is 13
        editor.focus()
        return event.preventDefault()
    return unless event.ctrlKey or not event.metaKey
    if event.which is 190
        slate.focus()
        return event.preventDefault()
    key = String.fromCharCode event.which
    return if key.toLowerCase() isnt 's'
    event.preventDefault()
    editor.set()

window.edit = editor.edit

window.run = (target) ->

    item = if target.isString() then get target else target
    if item then cosh.execute item.content, item.coshKey
    else toastr.error "Nothing at #{target}.", "Cosh API"

    undefined

window.put = (arg) ->

    color = '#BEBEBE'
    if arg is null then arg = "null"
    else if arg is undefined then return goToEnd()
    else if arg.isDate?() then arg = arg.format()
    else if arg.isString?()
        if arg then color = "#B2D019"
        else arg = "empty string"
    else
        try arg = pprint.parse(arg)
        catch error then arg = arg.toString()

    $div = jQuery("<xmp>").html arg
    if color then $div.css color: color
    unless $board.text() then append $div, "pprint"
    else append $div, "pprint unspaced"

    undefined

window.append = (tree, options) ->

    if tree.isString() then $tree = jQuery("<div>").html tree.compile "md"
    else if tree instanceof HTMLElement then $tree = jQuery tree
    else if tree instanceof jQuery then $tree = tree
    else return toastr.error "Unrenderable first arg.", "Cosh API"

    if options isnt undefined
        if options.isString?() then $tree.first().addClass options
        else $tree = options($tree)

    $board.append $tree

    if $tree[0].className is "page"
        jQuery("html")
        .animate { scrollTop: $tree.offset().top - 27 }, duration: 150
    else goToEnd()

    $tree.children("h1").each ->
        tail = ":".repeat 87 - this.innerText.length
        this.innerHTML += "<span style=color:#E18243> #{tail}</span>"

    $tree

window.peg = (args...) ->

    append(args...)?.addClass "unspaced"
    undefined

window.load = (path, async=false) ->

    jQuery.ajax
        url: path
        async: async
        success: (source) ->
            if path.endsWith ".coffee" then cosh.execute source, path
            else append source, "page"

    undefined

window.clear = -> $board.html("").shush

authStore = "coshGitHubAuth"

gistEndpoint = (path) -> "https://api.github.com#{path}"

auth = (args...) ->

    if args.length is 0
        authHash = get(authStore) or sessionStorage.getItem(authStore)
        if authHash?.isString() then JSON.parse authHash
        else authHash
    else set authStore, { username: args[0], password: args[1] }

authHeader = ->

    return unless authData = auth()
    authData = btoa "#{authData.username}:#{authData.password}"
    Authorization: "Basic #{authData}"

gist2chit = (gistHash) ->

    core = gistHash.files[gistHash.files.keys()[0]]
    chit
        coshKey: core.filename
        description: gistHash.description
        content: core.content
        gistId: gistHash.id
        owner: gistHash.owner.login
        galleryURL: "https://gallery-cosh.appspot.com/##{gistHash.id}"

jQuery("#auth-link").click ->

    formID = "coshID#{uniquePin()}"

    append """
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
            toastr.error "Username can't be empty.", "GitHub Auth"
            return $username.focus()
        unless $password.val()
            toastr.error "Password can't be empty.", "GitHub Auth"
            return $password.focus()

        auth $username.val(), $password.val()
        toastr.success "Credentials set to coshGitHubAuth.", "GitHub Auth"

    undefined

window.publish = (target, published=true) ->

    output = undefined

    if target.isString?() then target = get target
    unless target
        toastr.error "Hash not found.", "GitHub Gist"
        return
    unless authData = authHeader()
        toastr.error "Couldn't find credentials.", "GitHub Gist"
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
            toastr.error "Publishing failed, #{reason}.", "GitHub Gist"
        success: (data) ->
            output = gist2chit data
            toastr.success "Published new gist.", "GitHub Gist"

    output

window.push = (target) ->

    output = undefined

    if target.isString?() then target = get target
    unless target
        toastr.error "Hash not found.", "GitHub Gist"
        return
    unless target.gistId
        toastr.error "#{target.coshKey} is unpublished.", "GitHub Gist"
        return
    unless authData = authHeader()
        toastr.error "Auth failed.", "GitHub Gist"
        return

    data = description: target.description, files: {}
    data.files[target.coshKey] =
        filename: target.coshKey
        content: target.content

    jQuery.ajax
        type: "PATCH"
        data: JSON.stringify data
        async: false
        url: gistEndpoint "/gists/#{target.gistId}"
        headers: authData
        error: (result) ->
            reason = JSON.parse(result.responseText).message
            toastr.error "Push failed, #{reason}.", "GitHub Gist"
        success: (data) ->
            output = gist2chit data
            toastr.success "Pushed #{target.coshKey} .", "GitHub Gist"

    output

window.clone = (gistId) ->

    output = undefined

    jQuery.ajax
        type: "GET"
        async: false
        url: gistEndpoint "/gists/#{gistId}"
        success: (data) -> output = gist2chit data
        error: (data) -> toastr.error "Gist not found.", "GitHub Gist"

    output

window.gallery = (gistId) ->

    open "https://gallery-cosh.appspot.com/##{gistId}"
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
            toastr.error "Couldn't create chit from args.", "Cosh API"
            return

    options.coshKey = key
    options

pageCache = {}

get_href = (event) ->

    target = event.target
    event.preventDefault()
    href = target.href or target.parentNode.href
    if href.startsWith location.origin
        href = href.slice(location.origin.length)

    href

$board.on "click", ".page a", (event) ->
    path = get_href event
    if path.endsWith(".md")
        if file = pageCache[path] then append file, "page"
        else jQuery.get path, (file) ->
            pageCache[path] = file
            append file, "page"
    else open path

$board.on "mouseover", ".page a", (event) ->
    path = get_href event
    return unless path.endsWith(".md") or pageCache[path]
    jQuery.get path, (page) -> pageCache[path] = page

cosh.execute = (source, url) ->

    options = bare: true, sourceMap: true

    shell = if url then false else true
    if url?.endsWith(".coffee.md") or url?.endsWith(".litcoffee")
        options.literate = true

    try code = coffee.compile source, options
    catch error

        line = error.location.first_line
        column = error.location.first_column
        message = "Caught #{error.name}: #{error.message}"

        $board.append(
            jQuery "<div>"
            .attr "class", "bold"
            .append highlightTrace source, line, column
            .append jQuery("<xmp>").text message
            )

        slate.updateHistory source if shell
        slate.setValue ""
        return clock.scrollIntoView()

    if shell

        inputCount++
        slate.updateHistory source
        url = "slate#{inputCount}.js"
        jQuery("#slate_count").html inputCount + 1
        slate.setValue ""

    inputs[url] =
        name: url
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

    put result if shell

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

            origin = item.count + " [#{map.line}:#{map.column + 1}]"
            $traceDiv = jQuery("<div>").css "display": "inline"
            .append highlightTrace item.source, map.line - 1, map.column

        else

            origin = trace.file
            $traceDiv = jQuery """
                <div>
                <span class=error>JavaScriptError in
                <span class=bold>#{trace.methodName}</span>
                [#{trace.lineNumber}:#{trace.column}]</span>
                </div>
                """

        $countDiv = jQuery "<div>"
        .html "<span class=slate_counter>#{origin}</span><br><br>"
        $traceDiv.append $countDiv
        traceDivs.push $traceDiv

    $stackDiv = jQuery("<div>")
    loop
        $stackDiv.append traceDivs.pop()
        break unless traceDivs.length

    $messageDiv = jQuery("<xmp>").text(message).attr class: "bold unspaced"
    $stackDiv.append $messageDiv
    $board.append $stackDiv
    clock.scrollIntoView()

highlightTrace = (source, lineNumber, charNumber) ->

    escape = (line) -> line.escapeHTML().split(' ').join "&nbsp;"

    lines = source.lines()
    line  = lines[lineNumber]

    start = escape line.slice 0, charNumber
    end   = escape line.slice charNumber + 1

    char = line[charNumber]
    look = if char then "bold" else "error_missing_char"
    char = if char then escape char else "&nbsp;"

    lines[lineNumber] = "#{start}<span class=#{look}>#{char}</span>#{end}"

    for line, index in lines
        if index isnt lineNumber then lines[index] = escape line

    jQuery("<span class=error>").html lines.join "<br>"

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

goToEnd = ->

    document.getElementById("clock").scrollIntoView()
    undefined

jQuery("#home-link").click -> load "/docs/home.md"
jQuery("#more-link").click -> load "/docs/external.md"
jQuery("#book-link").click -> load "/docs/book/front.md"

worker = new Worker "/scripts/cosh/clock_worker.js"
worker.onmessage = (event) -> $clock.text event.data

jQuery('#footer').click -> slate.focus()

if galleryMode

    localStorage?.clear()
    sessionStorage?.clear()
    indexedDB?.deleteDatabase "*"

    window.mainFile = clone launchCode
    unless mainFile then $brand.text "fatal error: gist not found"
    else
        $brand.text("CoffeeShop Gallery").css color: "#E18243"
        edit set mainFile
        run mainFile

else

    unless get "config.coffee" then set chit "config.coffee",
        description: "Run on boot unless in safe mode."
        content: 'load "/docs/home.md"'

    $brand.css color: "#E18243"
    .text if launchCode is "safemode" then "Safe Mode" else "CoffeeShop"

    edit "config.coffee"
    run "config.coffee" if launchCode isnt "safemode"

    window.onbeforeunload = ->

        set historyStore, slate.history.last 400
        undefined

jQuery("#favicon").attr href: "/images/skull_up.png"
toastr.success "Powered by CoffeeScript (#{coffee.VERSION})", "CoffeeShop Beta"
slate.focus()

`//# sourceURL=/cosh/main.js`
