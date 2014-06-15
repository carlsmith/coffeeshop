define ->

    authStore = "coshGitHubAuth"

    endpoint = (path) -> "https://api.github.com#{path}"

    auth = (args...) ->

        if args.length is 0
            authHash = get(authStore) or sessionStorage.getItem(authStore)
            if authHash?.isString() then JSON.parse authHash
            else authHash
        else set authStore, { username: args[0], password: args[1] }

    authHeader = ->

        return if not authData = auth()
        authData = btoa "#{authData.username}:#{authData.password}"
        Authorization: "Basic #{authData}"

    gist2hash = (gistHash) ->

        core = gistHash.files[gistHash.files.keys()[0]]
        hash
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

            if not $username.val()
                toastr.error "Username can't be empty.", "GitHub Auth"
                return $username.focus()
            if not $password.val()
                toastr.error "Password can't be empty.", "GitHub Auth"
                return $password.focus()

            auth $username.val(), $password.val()
            toastr.success "Credentials set to coshGitHubAuth.", "GitHub Auth"

        undefined

    window.publish = (target, published=true) ->

        output = undefined

        if target.isString?() then target = get target
        if not target
            toastr.error "Hash not found.", "GitHub Gist"
            return
        if not authData = authHeader()
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
            url: endpoint "/gists"
            headers: authData
            error: (result) ->
                reason = JSON.parse(result.responseText).message
                toastr.error "Publishing failed, #{reason}.", "GitHub Gist"
            success: (data) ->
                output = gist2hash data
                toastr.success "Published new gist.", "GitHub Gist"

        output

    window.push = (target) ->

        output = undefined

        if target.isString?() then target = get target
        if not target
            toastr.error "Hash not found.", "GitHub Gist"
            return
        if not target.gistId
            toastr.error "#{target.coshKey} is unpublished.", "GitHub Gist"
            return
        if not authData = authHeader()
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
            url: endpoint "/gists/#{target.gistId}"
            headers: authData
            error: (result) ->
                reason = JSON.parse(result.responseText).message
                toastr.error "Push failed, #{reason}.", "GitHub Gist"
            success: (data) ->
                output = gist2hash data
                toastr.success "Pushed #{target.coshKey} .", "GitHub Gist"

        output

    window.clone = (gistId) ->

        output = undefined

        jQuery.ajax
            type: "GET"
            async: false
            url: endpoint "/gists/#{gistId}"
            success: (data) -> output = gist2hash data
            error: (data) -> toastr.error "Gist not found.", "GitHub Gist"

        output

    window.gallery = (gistId) ->

        open "https://gallery-cosh.appspot.com/##{gistId}"
        undefined

    window.hash = (args...) ->

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
                toastr.error "Invalid args.", "Hash Maker"
                return

        options.coshKey = key
        options
