define ["cs!core", "pprint"], (_, pprint) ->

    $board = jQuery "#board"

    goToEnd = ->
        document.getElementById("clock").scrollIntoView()
        undefined

    window.get = (key) ->
        item = localStorage.getItem key
        if item then JSON.parse item

    window.set = (args...) ->

        return if undefined in args
        switch args.length
            when 1 then [key, value] = [ args[0].coshKey, args[0] ]
            when 2 then [key, value] = args
            else return toastr.error "Wrong number of args.", "Cosh API"
        if not key
            toastr.error "Set failed, bad args.", "Cosh API"
            return
        if value.coshKey then value.coshKey = key
        localStorage.setItem key, JSON.stringify value
        editor.updateCurrentFile()

        value

    window.pop = (target) ->

        return toastr.error "Not enough args.", "Cosh API" if not target
        key = if target.isString?() then target else target.coshKey
        item = get key
        return toastr.error "Nothing at #{target}.", "Cosh API" if not item
        localStorage.removeItem key
        toastr.success "Popped #{target}", "Cosh API"
        editor.updateStatus()

        item

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
        if not $board.text() then append $div, "pprint"
        else append $div, "pprint chit"

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
        append(args...).addClass "chit"
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

    # Handle links in page elements and preloading docs on mouseover...

    page_cache = {}

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
            if file = page_cache[path] then append file, "page"
            else jQuery.get path, (file) ->
                page_cache[path] = file
                append file, "page"
        else open path

    $board.on "mouseover", ".page a", (event) ->
        path = get_href event
        return if not path.endsWith(".md") or page_cache[path]
        jQuery.get path, (page) -> page_cache[path] = page
