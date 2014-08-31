define ->

    currentFile = {}
    $nameDiv = jQuery "#filename"
    $descriptionDiv = jQuery "#file_description"
    $editorLinks = jQuery "#editor-links"

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
        name: "set_hash"
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
        return toastr.error "Nothing at #{target}.", "Cosh API" if not item

        if item.coshKey.endsWith(".coffee.md") or item.coshKey.endsWith(".litcoffee")
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
        return if not event.ctrlKey or not event.metaKey
        if event.which is 190
            slate.focus()
            return event.preventDefault()
        key = String.fromCharCode event.which
        return if key.toLowerCase() isnt 's'
        event.preventDefault()
        editor.set()

    window.edit = editor.edit
    editor
