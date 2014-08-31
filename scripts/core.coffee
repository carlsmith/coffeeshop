define [
    "cs!highlight_trace"
    "cs!stacktrace"
    "coffee-script"
    "lib/marked"
    "lib/sourcemap/source-map-consumer"
    ], (highlightTrace, stacktrace, coffee, marked, smc) ->

    window.cosh = uniquePin: 0
    window.uniquePin = -> cosh.uniquePin++

    jQuery.ajaxSetup cache: false
    marked.setOptions sanitize: false

    String::compile = (lang, args...) ->
        if lang in ["cs", "coffee", "coffeescript"]
            return coffee.compile this, args...
        if lang in ["md", "markdown"]
            return marked this, args...

    inputs = {}
    inputCount = 0
    $board = jQuery "#board"
    window.slate = ace.edit "slate"
    clock = document.getElementById "clock"
    slate_div = document.getElementById "slate"

    historyStore = "coshHistoryStore"
    history = localStorage.getItem historyStore
    if history is null then slate.history = []
    else slate.history = JSON.parse history
    pointer = slate.history.length
    stash = ""

    jQuery('#footer').click -> slate.focus()

    window.onbeforeunload = ->
        value = JSON.stringify slate.history.last 400
        localStorage.setItem historyStore, value
        return

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

    slate.reset = ->
        slate.history = []
        localStorage.setItem historyStore, JSON.stringify []
        return

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
            jQuery("#input_count").html inputCount + 1
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
        [stack, untraceable] = stacktrace(error.stack)
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

        $messageDiv = jQuery("<xmp>").text(message).attr class: "bold chit"
        $stackDiv.append $messageDiv
        $board.append $stackDiv
        clock.scrollIntoView()
