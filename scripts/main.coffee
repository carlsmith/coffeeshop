require ["cs!api", "cs!editor", "cs!github"], ->

    window.indexedDB = \
        indexedDB or
        mozIndexedDB or
        webkitIndexedDB or
        msIndexedDB

    $brand = jQuery "#brand"
    $slate = jQuery "#slate"
    $clock = jQuery "#clock"

    pagehash = location.hash.slice 1
    window.galleryMode = location.host is "gallery-cosh.appspot.com"

    if galleryMode
        localStorage?.clear()
        sessionStorage?.clear()
        indexedDB?.deleteDatabase "*"
        window.mainFile = clone pagehash
        if not mainFile then $brand.text "fatal error: gist not found"
        else
            $brand.text("CoffeeShop Gallery").css color: "#E18243"
            $favicon.attr href: "/images/skull_up.png"
            run mainFile
        return

    jQuery("#home-link").click -> load "/docs/home.md"
    jQuery("#more-link").click -> load "/docs/external.md"
    jQuery("#book-link").click -> load "/docs/book/front.md"

    worker = new Worker "/scripts/clock_worker.js"
    worker.onmessage = (event) -> $clock.text event.data

    if not get "config.coffee" then set hash "config.coffee",
        description: "Run on boot unless in safe mode."
        content: 'load "/docs/home.md"'

    jQuery "#slate, #editor, #footer, #shell-links, #editor-links"
    .css visibility: "visible"

    $brand
    .css color: "#E18243"
    .text if pagehash is "safemode" then "Safe Mode" else "CoffeeShop"

    edit "config.coffee"

    slate.focus()
    jQuery("#favicon").attr href: "/images/skull_up.png"
    toastr.success "A Better CoffeeScript Shell", "CoffeeShop"
    run "config.coffee" if pagehash isnt "safemode"
